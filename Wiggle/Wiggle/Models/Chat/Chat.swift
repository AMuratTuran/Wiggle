//
//  Message.swift
//  Wiggle
//
//  Created by Murat Turan on 8.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import MessageKit
import Parse

class Chat: Decodable {
    
    var objectId: String
    var lastMessage: String
    var senderId: String
    var remoteId: String
    var isRead: Bool
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {

        case lastMessage = "lastMessage"
        case senderId = "senderId"
        case remoteId = "remoteId"
        case createdAt
        case isRead
        case objectId
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lastMessage = try (values.decodeIfPresent(String.self, forKey: .lastMessage) ?? "")
        senderId = try (values.decodeIfPresent(String.self, forKey: .senderId) ?? "")
        remoteId = try (values.decodeIfPresent(String.self, forKey: .remoteId) ?? "")
        createdAt = try (values.decodeIfPresent(String.self, forKey: .createdAt) ?? "")
        let isReadNum = try (values.decodeIfPresent(Int.self, forKey: .isRead) ?? 0)
        isRead = isReadNum == 1 ? true : false
        objectId = try (values.decodeIfPresent(String.self, forKey: .objectId) ?? "")
    }
    
    init(dictionary: [String: Any]) {
        self.lastMessage = dictionary["lastMessage"] as? String ?? ""
        self.senderId = dictionary["senderId"] as? String ?? ""
        self.remoteId = dictionary["remoteId"] as? String ?? ""
        let isReadNum =  dictionary["isRead"] as? Int ?? 0
        isRead = isReadNum == 1 ? true : false
        let createdAtString = dictionary["createdAt"] as? String ?? ""
        self.createdAt = formatDate(dateString: createdAtString, outputFormat: "dd-MM-yy HH:mm:ss")
        self.objectId = dictionary["objectId"] as? String ?? ""
    }
    
    init (object: PFObject) {
        self.lastMessage = object["body"] as! String
        self.senderId = object["sender"] as! String
        self.remoteId = object["receiver"] as! String
        let isReadNum =  object["isRead"] as? Int ?? 0
        isRead = isReadNum == 1 ? true : false
        self.createdAt = object.createdAt?.prettyStringFromDate(dateFormat: "dd-MM-yy HH:mm:ss", localeIdentifier: "tr") ?? ""
        self.objectId = object["objectId"] as! String
    }
    
    func getReceiverId() -> String {
        if let currentUser = PFUser.current() {
            let id = currentUser.objectId
            if self.remoteId != id {
                return remoteId
            }else {
                return senderId
            }
        }else {
            return ""
        }
    }
    
    func isReceivedMessage() -> Bool {
        if let currentUser = PFUser.current() {
            let id = currentUser.objectId
            if id == senderId {
                return true
            }
        }
        return false
    }
}

extension Chat: Equatable {
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return (lhs.senderId == rhs.senderId && lhs.remoteId == rhs.remoteId)
    }
}

func formatDate(dateString: String, outputFormat: String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    let date = formatter.date(from: dateString)
    
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale(identifier: "tr")
    if let date = date {
        formatter.dateFormat = outputFormat
        let myStringafd = formatter.string(from: date)
        return myStringafd
    }else {
        return ""
    }
}

