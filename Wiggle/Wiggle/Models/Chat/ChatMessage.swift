//
//  ChatMessage.swift
//  Wiggle
//
//  Created by Murat Turan on 19.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import Parse
import MessageKit

class ChatMessage: MessageType {
    var sender: SenderType
    
    var sentDate: Date
    
    var kind: MessageKind
    
    var senderId: String
    var receiverId: String
    var body: String
    var isReceived: Bool = false
    var messageId: String
    var isRead: Bool
        
    init(dictionary: PFObject) {
        self.sender = SenderModel(senderId: dictionary["sender"] as? String ?? "", displayName: "")
        self.sentDate = dictionary.createdAt ?? Date()
        self.kind = .text(dictionary["body"] as? String ?? "")
        self.senderId = dictionary["sender"] as? String ?? ""
        self.receiverId = dictionary["receiver"] as? String ?? ""
        self.body = dictionary["body"] as? String ?? ""
        let isReadNum = dictionary["isRead"] as? Int ?? 0
        isRead = isReadNum == 1 ? true : false
        if let currentUser = PFUser.current() {
            if let myId = currentUser.objectId, myId == senderId {
                self.isReceived = false
            }else {
                self.isReceived = true
            }
        }
        self.messageId = dictionary.objectId ?? "" 
    }
}


struct SenderModel: SenderType {
    var senderId: String
    
    var displayName: String
    
    init(senderId: String, displayName: String ) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
