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

class Chat: Decodable  {
    
    var lastMessage: String
    var senderId: String
    var remoteId: String
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {

        case lastMessage = "lastMessage"
        case senderId = "senderId"
        case remoteId = "remoteId"
        case createdAt
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lastMessage = try (values.decodeIfPresent(String.self, forKey: .lastMessage) ?? "")
        senderId = try (values.decodeIfPresent(String.self, forKey: .senderId) ?? "")
        remoteId = try (values.decodeIfPresent(String.self, forKey: .remoteId) ?? "")
        createdAt = try (values.decodeIfPresent(String.self, forKey: .createdAt) ?? "")
    }
    
    init(dictionary: [String: Any]) {
        self.lastMessage = dictionary["lastMessage"] as? String ?? ""
        self.senderId = dictionary["senderId"] as? String ?? ""
        self.remoteId = dictionary["remoteId"] as? String ?? ""
        let createdAtString = dictionary["createdAt"] as? String ?? ""
        self.createdAt = formatDate(dateString: createdAtString, outputFormat: "dd-MM-yy HH:mm:ss")
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

