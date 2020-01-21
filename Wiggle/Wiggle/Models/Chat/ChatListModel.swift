//
//  ChatListModel.swift
//  Wiggle
//
//  Created by Murat Turan on 18.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import Parse

class ChatListModel {
    var receiverName: String = ""
    var receiverId: String
    var lastMessage: String = ""
    var dateString: String = ""
    var imageUrl: String?
    var createdAt: Date = Date()
    var isReceivedMessage: Bool = false
    var firstName: String = ""
    var lastName: String = ""
    var myId: String = ""
    var isRead: Bool = false
    var objectId: String = ""
    var isImageMessage: Bool
    
    init(user: PFUser, chat: Chat) {
        if let receiverFirstName = user["first_name"] as? String, let receiverLastName = user["last_name"] as? String{
            self.firstName = receiverFirstName
            self.lastName = receiverLastName
            self.receiverName = "\(receiverFirstName) \(receiverLastName)"
        }
        
        if let thumbnail = user["photo"] as? PFFileObject {
            self.imageUrl = thumbnail.url
        }
        
        if let id = user.objectId {
            self.receiverId = id
        }else {
            self.receiverId = ""
        }
        
        isImageMessage = chat.isImageMessage
        
        if let currentUser = PFUser.current(), let id = currentUser.objectId {
            self.myId = id
        }
        
        self.isReceivedMessage = chat.isReceivedMessage()
        
        lastMessage = chat.lastMessage
        if let createdAt = chat.createdAt.dateFromStringWithFormat("dd-MM-yy HH:mm:ss") {
            self.createdAt = createdAt
            if createdAt.isInToday {
                dateString = createdAt.prettyStringFromDate(dateFormat: "HH:mm", localeIdentifier: "tr")
            }else if createdAt.isInThisWeek{
                dateString = createdAt.prettyStringFromDate(dateFormat: "EEEE", localeIdentifier: "tr")
            }else if createdAt.isInThisMonth || createdAt.isInThisYear {
                dateString = createdAt.prettyStringFromDate(dateFormat: "dd MMM", localeIdentifier: "tr")
            }else {
                dateString = createdAt.prettyStringFromDate(dateFormat: "dd.MM.yyyy", localeIdentifier: "tr")
            }
        }
        self.isRead = chat.isRead
        self.objectId = chat.objectId
    }
    
    func getFullName() -> String {
        return "\(self.firstName) \(self.lastName)"
    }
    
}

extension ChatListModel: Equatable {
    static func == (lhs: ChatListModel, rhs: ChatListModel) -> Bool {
        return lhs.receiverId == rhs.receiverId
    }
}
