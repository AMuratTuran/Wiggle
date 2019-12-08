//
//  ChatViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 8.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import MessageUI

class ChatViewController: MessagesViewController {
    
    private var messages: [MessageType] = []
    var circleView = UIView()
    var profileIV = UIImageView()
    var nameView = UIView()
    var nameLabel = UILabel()
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    let user = MockUser(senderId: "asdasdasd", displayName: "Murat Turan")
    var myUser: MockUser {
        return user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        addProfilePhotoNavigationBar()
        configureMessageCollectionView()
        configureMessageCollectionViewLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        messagesCollectionView.contentInset.bottom = messageInputBar.frame.height
        messagesCollectionView.scrollIndicatorInsets.bottom = messageInputBar.frame.height
        if #available(iOS 13.0, *) {
            messagesCollectionView.backgroundColor = .systemBackground
        } else {
            messagesCollectionView.backgroundColor = .white
        }
    }
    
    override func viewWillLayoutSubviews() {
        configureMessageInputBar()
    }
    func configureMessageCollectionView() {
        configureMessageCollectionViewLayout()
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        // MARK: Delegates
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messageInputBar.delegate = self
    }
    
    func configureMessageCollectionViewLayout() {
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 8)
        
        // MARK: Outgoing message padding
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        
        // MARK: Incoming message padding
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 18))
        
        // MARK: Accessory view padding
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    }
    
    func addProfilePhotoNavigationBar() {
        circleView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        circleView.layer.borderColor = UIColor.systemPink.cgColor
        circleView.layer.borderWidth = 2
        circleView.layer.cornerRadius = circleView.frame.width / 2
        // user image
        profileIV = UIImageView(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
        profileIV.layer.cornerRadius = profileIV.frame.width / 2
        profileIV.layer.masksToBounds = true
        profileIV.contentMode = .scaleToFill
        profileIV.isUserInteractionEnabled = true
        profileIV.kf.setImage(with: URL(string: "http://lorempixel.com/400/400/people/\(Int.random(in: 1...10))"))
        
        circleView.isUserInteractionEnabled = true
        circleView.addSubview(profileIV)
        circleView.addSubview(nameView)
        let name = "Murat"
        let lastName = "Turan"
        title = name + " " + lastName
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: circleView)
    }
    
    func configureMessageInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor =  UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 12, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.autocorrectionType = .no
        messageInputBar.shouldAutoUpdateMaxTextViewHeight = false
        messageInputBar.maxTextViewHeight = 100

        messageInputBar.inputTextView.placeholder = "Mesajiniz"
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 141/255, green: 141/255, blue: 141/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.5
        messageInputBar.inputTextView.layer.cornerRadius = 20.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.delegate = self
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        messageInputBar.sendButton.backgroundColor = UIColor.gray
        messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.sendButton.setSize(CGSize(width: 40, height: 40), animated: false)
        messageInputBar.sendButton.image = UIImage(named: "icon_smartsearch_message")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.layer.cornerRadius =  20
        messageInputBar.sendButton.contentMode = .center
        messageInputBar.sendButton.imageView?.contentMode = .center
        messageInputBar.sendButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 4, bottom: 4, right: 7)
        messageInputBar.middleContentViewPadding.right = 8
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.2, animations: {
                    item.backgroundColor = UIColor.systemPink
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.2, animations: {
                    item.backgroundColor = UIColor.gray
                })
        }
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return myUser
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return ChatMessageViewModel(messageModel: ChatReceivedMessageModel())
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 20
    }
}

extension ChatViewController: MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
    }
}


extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("message tapped")
        //TODO: -> interactor -> worker'daki getMessageKind'ı çağır.
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("cell top label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("cell bottom label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("message top label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("message bottom label tapped")
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("audio started")
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("audio paused")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("audio stopped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("accessory view tapped")
    }
}

struct MockUser: SenderType {
    var senderId: String
    var displayName: String
}

final class ChatMessageViewModel: MessageType {
    var sentDate: Date
    
    
    var messageModel: ChatReceivedMessageModel!
    
    var sender: SenderType {
        return mockUser
    }
    var messageId: String
    var kind: MessageKind
    var mockUser: MockUser
    
    var room: String?
    var message: String?
    var userToConnect: String?
    var userFullName: String?
    var senderId: String?
    var senderPhotoUrl: String?
    var creationTimestamp: Int64?
    var prevTimeStamp: Int64?
    
    init(messageModel: ChatReceivedMessageModel) {
        self.messageModel = messageModel
        self.room = messageModel.room
        self.message = messageModel.message
        self.userToConnect = messageModel.userToConnect
        self.userFullName = messageModel.userFullName
        self.senderId = messageModel.senderId
        self.senderPhotoUrl = messageModel.senderPhotoUrl
        self.creationTimestamp = messageModel.creationTimestamp
        self.messageId = messageModel.messageId ?? ""
        self.kind = .text(messageModel.message ?? "")
        let displayName = "Murat Turan"
        self.mockUser = MockUser(senderId: messageModel.senderId ?? "", displayName: displayName)
        self.prevTimeStamp = 0
        self.sentDate = Date()
    }
    
}

class ChatReceivedMessageModel {
    var room: String?
    var message: String?
    var userToConnect: String?
    var userFullName: String?
    var senderId: String?
    var senderPhotoUrl: String?
    var creationTimestamp: Int64?
    var messageId: String?
    
    init(room: String, message: String, userToConnect: String, userFullName: String, senderId: String, senderPhotoUrl: String, creationTimestamp: Int64, messageId: String) {
        self.room = room
        self.message = message
        self.userToConnect = userToConnect
        self.userFullName = userFullName
        self.senderId = senderId
        self.senderPhotoUrl = senderPhotoUrl
        self.creationTimestamp = creationTimestamp
        self.messageId = messageId
    }
    
    init() {
        let messages:[String] = ["Selam", "Napiyorsun", "Merhaba", "Nasil gidiyor"]
        self.message = messages[Int.random(in: 0...3)]
    }
    
    enum CodingKeys: String, CodingKey {
        case room
        case message
        case userToConnect
        case userFullName
        case senderId
        case senderPhotoUrl
        case creationTimestamp
        case messageId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        room = try values.decode(String.self, forKey: .room)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        userToConnect = try values.decode(String.self, forKey: .userToConnect)
        userFullName = try values.decode(String.self, forKey: .userFullName)
        senderId =  try values.decode(String.self, forKey: .senderId)
        senderPhotoUrl = try values.decode(String.self, forKey: .senderPhotoUrl)
        creationTimestamp = try values.decode(Int64.self, forKey: .creationTimestamp)
        messageId = try values.decode(String.self, forKey: .messageId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(room, forKey: .room)
        try container.encode(message, forKey: .message)
        try container.encode(userToConnect, forKey: .userToConnect)
        try container.encode(userFullName, forKey: .userFullName)
        try container.encode(senderId, forKey: .senderId)
        try container.encode(senderPhotoUrl, forKey: .senderPhotoUrl)
        try container.encode(creationTimestamp, forKey: .creationTimestamp)
        try container.encode(messageId, forKey: .messageId)
    }
}

extension ChatViewController: UITextViewDelegate {
    
}
