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

typealias JSON = [String: AnyObject]

protocol JsonInitializable {
    init (json: JSON) throws
}

struct NetworkManager {
    
    static func sendSMSCode(_ request: SMSCodeRequest, success: @escaping(Int) -> Void, fail: @escaping(String) -> Void) {
        PFCloud.callFunction(inBackground: "SendSMS", withParameters: request.toDict()) { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            guard let smsCode = response as? Int else {
                fail(Localize.Common.GeneralError)
                return
            }
            success(smsCode)
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
        messageObject.saveEventually { (isSuccess, error) in
            if let error = error {
                fail(error.localizedDescription)
            }
            success(isSuccess)
        }
    }
    
    static func getChatHistory(myId: String, contactedId: String, success: @escaping([ChatMessage]) -> Void, fail: @escaping(String) -> Void) {
        let query1 = PFQuery(className:"Messages")
        query1.whereKey("sender", equalTo: myId)
        query1.whereKey("receiver", equalTo: contactedId)
        let query2 = PFQuery(className:"Messages")
        query2.whereKey("sender", equalTo: contactedId)
        query2.whereKey("receiver", equalTo: myId)
        
        let query = PFQuery.orQuery(withSubqueries: [query1, query2])
        query.addDescendingOrder("createdAt")
        query.limit = 50
        let liveQueryClient = ParseLiveQuery.Client()
        let handling = liveQueryClient.subscribe(query)
        handling.handle(Event.created) { (_, object) in
            print(object)
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
    
    // MARK : HomeScreen User Functions
    static func getUsersForSwipe(success: @escaping([WiggleCardModel]) -> Void, fail: @escaping(String) -> Void) {
        let query : PFQuery? = PFUser.query()
        query?.limit = 20
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
                            var wiggleCardModels = [WiggleCardModel]()
                            let wiggleUserModel = ModelParser.PFUserToWiggleCardModel(user: user)
                            wiggleCardModels.append(wiggleUserModel)
                            success(wiggleCardModels)
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
}


