//
//  NetworkManager.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import Parse
import PromiseKit
import ParseLiveQuery
import Koloda
import PopupDialog
import Alamofire

struct NetworkManager {
    
    static func emailLogin(_ request: EmailLoginRequest, success: @escaping(Bool) -> Void, fail: @escaping(String) -> Void) {
        PFUser.logInWithUsername(inBackground: request.email, password: request.password) {(user, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            guard let userInfo = user else {
                return
            }
            UserDefaults.standard.set(userInfo.sessionToken, forKey: AppConstants.UserDefaultsKeys.SessionToken)
            if let _ = userInfo["gender"] as? Int, let userName = userInfo["first_name"] as? String {
                if userName.isEmpty {
                     success(false)
                }else {
                    success(true)
                }
            }else {
                success(true)
            }
        }
    }
    
    static func auth(_ request: PhoneAuthRequest, success: @escaping(Bool) -> Void, fail: @escaping(String) -> Void) {
        PFCloud.callFunction(inBackground: "Auth", withParameters: request.toDict()) { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            guard let sessionToken = response as? String else {
                fail("Invalid Token")
                return
            }
            
            UserDefaults.standard.set(sessionToken, forKey: AppConstants.UserDefaultsKeys.SessionToken)
            PFUser.become(inBackground: sessionToken) { (user, error) in
                if let error = error {
                    fail(error.localizedDescription)
                    return
                }
                guard let user = user else {
                    fail("No user data")
                    return
                }
                user.fetchInBackground { (user, error) in
                    if let error = error {
                        fail(error.localizedDescription)
                        return
                    }
                    
                    guard let userInfo = user else {
                        fail("No user data")
                        return
                    }
                    if let _ = userInfo["gender"] as? Int, let userName = userInfo["first_name"] as? String {
                        if userName.isEmpty {
                            success(false)
                        }else {
                            success(true)
                        }
                    }else {
                        success(false)
                    }
                }
            }
        }
    }
    
    static func getChatList(success: @escaping([Chat]) -> Void, fail: @escaping(String) -> Void)  {
        PFCloud.callFunction(inBackground: "Messages", withParameters: nil) { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            
            guard let chats = response as? NSArray else {
                fail(Localize.Common.GeneralError)
                return
            }
            
            var chatResponse:[Chat] = []
            
            chats.forEach { (chatModel) in
                if let dict = chatModel as? [String: Any]{
                    let chat = Chat(dictionary: dict)
                    chatResponse.append(chat)
                }else {
                    fail(Localize.Common.GeneralError)
                }
            }
            let sortedData = chatResponse.sorted {
                $0.createdAt.dateFromStringWithFormat("dd-MM-yy HH:mm:ss")! > $1.createdAt.dateFromStringWithFormat("dd-MM-yy HH:mm:ss")!
            }
            success(sortedData)
        }
    }
    
    static func queryUsersById(_ id: String, success: @escaping(PFUser) -> Void, fail: @escaping(String) -> Void) {
        let query : PFQuery? = PFUser.query()
        query?.whereKey("objectId", equalTo: id)
        query?.findObjectsInBackground { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            
            guard let userResponse = response as NSArray? else {
                fail(Localize.Common.GeneralError)
                return
            }
            
            userResponse.forEach { (user) in
                if let dict = user as? PFObject {
                    dict.fetchInBackground { (object, error) in
                        if let user = object as? PFUser {
                            success(user)
                        }else {
                            fail(Localize.Common.GeneralError)
                        }
                    }
                }else {
                    fail(Localize.Common.GeneralError)
                }
            }
        }
    }
    
    static func queryFriendsByReceiverId(_ receiverId: String, success: @escaping([Match]) -> Void, fail: @escaping(String) -> Void) {
        let query = PFQuery(className:"Friends")
        query.whereKey("receiver", equalTo: receiverId)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                fail(error.localizedDescription)
            } else if let objects = objects as? [Match] {
                success(objects)
            }
        }
    }
    
    static func sendTextMessage(messageText: String, senderId: String, receiverId: String, success: @escaping(Bool) -> Void, fail: @escaping(String) -> Void ) {
        let messageObject: PFObject = PFObject(className: "Messages")
        messageObject.setValue(messageText, forKey: "body")
        messageObject.setValue(senderId, forKey: "sender")
        messageObject.setValue(receiverId, forKey: "receiver")
        messageObject.setValue(0, forKey: "isRead")
        messageObject.saveEventually { (isSuccess, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            success(isSuccess)
        }
    }
    
    static func sendImageMessage(image: Data, senderId: String, receiverId: String, success: @escaping(Bool) -> Void, fail: @escaping(String) -> Void ) {
        let messageObject: PFObject = PFObject(className: "Messages")
        let imageFile = PFFileObject(name:"image.png", data:image)
        
        messageObject.setValue(imageFile, forKey: "file")
        messageObject.setValue(senderId, forKey: "sender")
        messageObject.setValue(receiverId, forKey: "receiver")
        messageObject.setValue(0, forKey: "isRead")
        messageObject.saveInBackground { (isSuccess, error) in
            if let error = error {
                fail(error.localizedDescription)
            }else {
                success(isSuccess)
            }
        }
    }
    
    static func getChatHistory(myId: String, contactedId: String, skipCount: Int, success: @escaping([ChatMessage]) -> Void, fail: @escaping(String) -> Void) {
        let query1 = PFQuery(className:"Messages")
        query1.whereKey("sender", equalTo: myId)
        query1.whereKey("receiver", equalTo: contactedId)
        let query2 = PFQuery(className:"Messages")
        query2.whereKey("sender", equalTo: contactedId)
        query2.whereKey("receiver", equalTo: myId)
        let query = PFQuery.orQuery(withSubqueries: [query1, query2])
        query.addDescendingOrder("createdAt")
        query.limit = 50
        query.skip = skipCount
        let liveQueryClient = ParseLiveQuery.Client()
        let handling = liveQueryClient.subscribe(query)
        handling.handle(Event.created) { (_, object) in
            print(object)
        }
        
        query2.findObjectsInBackground { (objects: [PFObject]?, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            
            guard let chatHistory = objects else {
                fail(Localize.Common.GeneralError)
                return
            }
            
            objects?.forEach {
                $0.setValue(1, forKey: "isRead")
                $0.saveInBackground()
            }
        }
        
        query.findObjectsInBackground { (objects: [PFObject]?, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            
            guard let chatHistory = objects else {
                fail(Localize.Common.GeneralError)
                return
            }
            
            var chatResponse:[ChatMessage] = []
            
            chatHistory.forEach { (chatMessageModel) in
                let chat = ChatMessage(dictionary: chatMessageModel)
                chatResponse.append(chat)
            }
            let sortedData = chatResponse.sorted {
                $0.sentDate < $1.sentDate
            }
            success(sortedData)
        }
        
    }
    
    static func deleteChat(chat: ChatListModel, success: @escaping() -> Void, fail: @escaping(String) -> Void) {
        let query1 = PFQuery(className:"Messages")
        query1.whereKey("sender", equalTo: chat.myId)
        query1.whereKey("receiver", equalTo: chat.receiverId)
        let query2 = PFQuery(className:"Messages")
        query2.whereKey("sender", equalTo: chat.receiverId)
        query2.whereKey("receiver", equalTo: chat.myId)
        let query = PFQuery.orQuery(withSubqueries: [query1, query2])
        query.findObjectsInBackground { (objects: [PFObject]?, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            if let objects = objects {
                for object in objects {
                    object.deleteInBackground { (result, error) in
                        if let error = error {
                            fail(error.localizedDescription)
                            return
                        }
                        success()
                    }
                }
            }
        }
    }
    
    // MARK : HomeScreen User Functions
    static func getUsersForSwipe(withSkip : Int, success: @escaping([WiggleCardModel]) -> Void, fail: @escaping(String) -> Void) {
        let likesQuery : PFQuery = PFQuery(className:"Likes")
        let query : PFQuery? = PFUser.query()
        let gender = PFUser.current()?.getGender()
        guard let user = PFUser.current() else {
            fail("User not found")
            return
        }
        let location = PFUser.current()?.getLocation()
        let parseLocation: PFGeoPoint = PFGeoPoint(latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0)
        likesQuery.whereKey("sender", equalTo: user.objectId ?? "")
        query?.limit = 10
        query?.skip = withSkip
        query?.whereKey("objectId", notEqualTo: user.objectId ?? "")
        query?.whereKey("location", nearGeoPoint: parseLocation, withinKilometers: Double(AppConstants.Settings.SelectedDistance))
        if AppConstants.Settings.SelectedShowMeGender != 3 {
            query?.whereKey("gender", equalTo: AppConstants.Settings.SelectedShowMeGender)
        }else {
            
        }
        query?.whereKey("objectId", doesNotMatchKey: "receiver", in: likesQuery)
        query?.order(byDescending: "popular")
        
        query?.findObjectsInBackground { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            
            guard let userResponse = response as NSArray? else {
                fail(Localize.Common.GeneralError)
                return
            }
            let wiggleCardModels = ModelParser.PFUserToWiggleCardModel(user: userResponse as? [PFUser] ?? [])
            success(wiggleCardModels)
        }
    }
    
    static func getDiscoveryUsers(heartRate: Int? = nil, withSkip : Int, success: @escaping([PFUser]) -> Void, fail: @escaping(String) -> Void) {
        let likesQuery : PFQuery = PFQuery(className:"Likes")
        let query : PFQuery? = PFUser.query()
        guard let user = PFUser.current() else {
            fail("User not found")
            return
        }
            
        likesQuery.whereKey("sender", equalTo: user.objectId ?? "")
        query?.limit = 50
        query?.skip = withSkip
        query?.whereKey("objectId", notEqualTo: user.objectId ?? "")
        
        if AppConstants.Settings.SelectedShowMeGender != 3 {
            query?.whereKey("gender", equalTo: AppConstants.Settings.SelectedShowMeGender)
        }else {
            
        }
        
        if let heartRate = heartRate {
            query?.whereKey("beat", greaterThan: heartRate - 20)
            query?.whereKey("beat", lessThan: heartRate + 20)
        }else {
            if let latitude = User.current?.latitude, let longitude = User.current?.longitude {
                let parseLocation: PFGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
                query?.whereKey("location", nearGeoPoint: parseLocation, withinKilometers: Double(AppConstants.Settings.SelectedDistance))
            }
        }
        
        query?.whereKey("objectId", doesNotMatchKey: "receiver", in: likesQuery)
        query?.order(byDescending: "updatedAt")
        
        query?.findObjectsInBackground { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            
            guard let userResponse = response as? [PFUser] else {
                fail(Localize.Error.Generic)
                return
            }
            success(userResponse)
        }
    }
    
    static func updateSuperLikeCount(count : Int){
        let final = PFUser.current()?.getSuperLike() ?? 0 + count
        
        PFUser.current()?.setValue(final, forKey: "super_like")
        
        PFUser.current()?.saveInBackground { (result, err) in
            print(result)
        }
    }
    
    static func updateSubstriction(sku : String){
        guard let user = PFUser.current() else {
            return
        }
        
        PFUser.current()?.setValue(user.objectId, forKey: "userId")
        PFUser.current()?.setValue(sku, forKey: "sku")
        
        PFUser.current()?.saveInBackground { (result, err) in
            print(result)
        }
    }
    
    static func swipeActionWithDirection(receiver : String, action : ActionType, success: @escaping() -> Void, fail: @escaping(String) -> Void){
        let object = PFObject(className: "Likes")
        object.setValue(AppConstants.objectId, forKey: "sender")
        object.setValue(receiver, forKey: "receiver")
        
        switch action {
        case .dislike:
            object.setValue("Left", forKey: "direction")
        case .like:
            object.setValue("Right", forKey: "direction")
        case .superlike:
            object.setValue("Top", forKey: "direction")
        }
        
        object.saveInBackground { (result, err) in
            if result{
                success()
            }else{
                fail(err.debugDescription)
            }
        }
    }
    
    static func unMatch(myId: String, contactedUserId: String, success: @escaping() -> Void, fail: @escaping(Error?) -> Void) {
        let object = PFObject(className: "Unmatches")
        object.setValue(AppConstants.objectId, forKey: "userId")
        object.setValue(contactedUserId, forKey: "peerId")
        object.saveInBackground { (result, err) in
            if result {
                success()
            }else {
                fail(err)
            }
        }
    }
    
    static func getHeartRateMatches(heartRate: Int, success: @escaping([PFUser]) -> Void, fail: @escaping(String) -> Void) {
        let query : PFQuery? = PFUser.query()
        query?.limit = 20
        query?.order(byDescending: "popular")
        query?.whereKey("beat", greaterThan: heartRate - 20)
        query?.whereKey("beat", lessThan: heartRate + 20)
        if AppConstants.Settings.SelectedShowMeGender != 3 {
            query?.whereKey("gender", equalTo: AppConstants.Settings.SelectedShowMeGender)
        }
        query?.findObjectsInBackground { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            guard let userResponse = response as NSArray? else {
                fail(Localize.Common.GeneralError)
                return
            }
            success(userResponse as? [PFUser] ?? [])
        }
    }
    
    static func getMatchedUsers(success: @escaping([PFUser]) -> Void, fail: @escaping(String) -> Void) {
        guard let user = PFUser.current() else {
            success([])
            return
        }
        let relation = user.relation(forKey: "friends")
        let query: PFQuery = relation.query()
        query.order(byDescending: "updatedAt")
        query.whereKeyExists("photo")
        
        query.findObjectsInBackground { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            guard let userResponse = response as NSArray? else {
                fail(Localize.Common.GeneralError)
                return
            }
            success(userResponse as? [PFUser] ?? [])
        }
    }
    
    static func getWhoLikedYou(success: @escaping([PFObject]) -> Void, fail: @escaping(String) -> Void) {
        let likesQuery : PFQuery = PFQuery(className:"Likes")
        guard let user = PFUser.current(), let myId =  user.objectId else {
            fail("Error")
            return
        }
        likesQuery.whereKey("receiver", equalTo: myId)
        likesQuery.whereKey("direction", equalTo: "Right")
        likesQuery.addDescendingOrder("createdAt")
        likesQuery.findObjectsInBackground { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            guard let userResponse = response as NSArray? else {
                fail(Localize.Common.GeneralError)
                return
            }
            success(userResponse as? [PFObject] ?? [])
        }
    }
    
    static var baseURL = URL(string: "/v1/")
}


extension NetworkManager {
    
    static func promise<T: JsonInitializable>(_ method: Alamofire.HTTPMethod, path: String, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = JSONEncoding.default, customUrl: URL? = nil) -> Promise<T> {
        return Promise<AnyObject?> { seal in
            
            let baseUrl = customUrl == nil ? NetworkManager.baseURL : customUrl!
            
            guard let encodePath = path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                let url = URL(string: encodePath, relativeTo: baseUrl) else {
                    throw RouterError.serverError(message: Localize.Error.Generic)
            }
            
            AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: AppConstants.ApiHeaders)
                .responseJSON { response in
                    
                    switch response.result {
                    case .success:
                        seal.fulfill(response.value as AnyObject?)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
            }.compactMap { data -> T in
                return try apiSuccessWithErrorRecover(data: data)
            }.recover { error -> Promise<T> in
                throw apiErrorRecovery(error: error, parameters: ["class": String(describing: T.self), "path": path, "method": method.rawValue])
        }
    }
    
    static func cancelRequest(_ path: String) {
        guard let encodePath = path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
                return
        }
        
        Alamofire.Session.default.session.getAllTasks { tasks in
            tasks.forEach({ task in
                if let url = task.originalRequest?.url?.absoluteString, url.contains(encodePath) {
                    task.cancel()
                }
            })
        }
    }
}

func apiSuccessWithErrorRecover<T: JsonInitializable>(data: AnyObject?) throws -> T {
    if let error = data?["error"] as? [String: AnyObject], let message = error["message"] as? String {
        
        guard let returnUrl = error["returnUrl"] as? String, !returnUrl.isEmpty else {
            throw RouterError.serverError(message: message)
        }
                    
        throw RouterError.hiddenError
    }
    
    var jsonData: [String: AnyObject]?
    
    if let j = data?["data"] as? [String: AnyObject] {
        jsonData = j
    }
    
    guard let json = jsonData else {
        throw RouterError.dataTypeMismatch
    }
    
    return try T(json: json)
}


func apiErrorRecovery(error: Error, parameters: [String: Any]) -> Error {
    switch error {
    case CastingError.failure(let key):
        var params = parameters
        params["key"] = key
            
        print("CASTING ERROR -> \(params.description)")

        return error
    default:
        return error
    }
}

public enum CastingError: Error {
    case failure(key: String)
}
