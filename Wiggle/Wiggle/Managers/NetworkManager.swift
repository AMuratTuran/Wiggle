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

typealias JSON = [String: AnyObject]

protocol JsonInitializable {
    init (json: JSON) throws
}

struct NetworkManager {
    
    static func sendSMSCode(_ request: EmailLoginRequest, success: @escaping(Int) -> Void, fail: @escaping(String) -> Void) {
        PFCloud.callFunction(inBackground: "SendSMS", withParameters: request.toDict()) { (response, error) in
            if let error = error {
                fail("Error")
                return
            }
            guard let smsCode = response as? Int else {
                fail(Localize.Common.GeneralError)
                return
            }
            success(smsCode)
        }
    }
    
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
    
    static func updateSuperLikeCount(count : Int){
        guard let user = PFUser.current() else {
            return
        }
        let object = PFObject(className:"User")
        let final = user.getSuperLike() + count
        
        object.setValue(final, forKey: "super_like")
        
        object.saveInBackground { (result, err) in
            print(result)
        }
    }
    
    static func updateSubstriction(sku : String){
        guard let user = PFUser.current() else {
            return
        }
        let object : PFObject = PFObject(className: "Subscriptions")
        
        object.setValue(user.objectId, forKey: "userId")
        object.setValue(sku, forKey: "sku")
        
        object.saveInBackground { (result, err) in
            print(result)
        }
    }
    
    static func swipeActionWithDirection(receiver : String, direction : SwipeResultDirection, success: @escaping() -> Void, fail: @escaping(String) -> Void){
        let object = PFObject(className: "Likes")
        object.setValue(AppConstants.objectId, forKey: "sender")
        object.setValue(receiver, forKey: "receiver")
        
        switch direction {
        case .left:
            object.setValue("Left", forKey: "direction")
        case .right:
            object.setValue("Right", forKey: "direction")
        case .up:
            object.setValue("Top", forKey: "direction")
        default:
            print("Unnecessary Direction : \(direction)")
        }
        
        object.saveInBackground { (result, err) in
            if result{
                success()
            }else{
                fail(err.debugDescription)
            }
        }
    }
    
    static func unMatch(myId: String, contactedUserId: String, success: @escaping() -> Void, fail: @escaping(String) -> Void) {
        let object = PFObject(className: "Unmatches")
        object.setValue(AppConstants.objectId, forKey: "userId")
        object.setValue(contactedUserId, forKey: "peerId")
        object.saveInBackground { (result, err) in
            if result {
                success()
            }else {
                fail(err?.localizedDescription ?? "")
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
        likesQuery.whereKey("direction", equalTo: "left")
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
}


