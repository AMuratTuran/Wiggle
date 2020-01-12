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
import Parse
import ParseLiveQuery

class ChatViewController: MessagesViewController {
    
    var currentUser: PFUser!
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
    var contactedUser: ChatListModel?
    let user = MockUser(senderId: "asdasdasd", displayName: "Murat Turan")
    var myUser: MockUser {
        return user
    }
    var chatHistory: [ChatMessage] = []
    var subscription: Subscription<PFObject>?
    var liveQueryClient: ParseLiveQuery.Client!
    let query1 = PFQuery(className:"Messages")
    let query2 = PFQuery(className:"Messages")
    var query: PFQuery<PFObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = PFUser.current() else {
            return
            // navigate to login
        }
        self.currentUser = currentUser
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.title = ""
        addProfilePhotoNavigationBar()
        configureMessageCollectionView()
        configureMessageCollectionViewLayout()
        getChatHistory()
        listenMessages()
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
    
    func listenMessages() {
        guard let contactedUser = contactedUser else { return }
        
        query1.whereKey("sender", equalTo: contactedUser.myId)
        query1.whereKey("receiver", equalTo: contactedUser.receiverId)
        
        query2.whereKey("sender", equalTo: contactedUser.receiverId)
        query2.whereKey("receiver", equalTo: contactedUser.myId)
        
        query = PFQuery.orQuery(withSubqueries: [query1, query2])
        query.addAscendingOrder("createdAt")
        query.limit = 50
        
        liveQueryClient = ParseLiveQuery.Client(server: AppConstants.ParseConstants.LiveQueryServer, applicationId: AppConstants.ParseConstants.ApplicationId, clientKey: AppConstants.ParseConstants.ClientKey)
        subscription = liveQueryClient.subscribe(query)
        _ = subscription?.handle(Event.created) { (_, response) in
            let incomingMessage:ChatMessage = ChatMessage(dictionary: response)
            self.insertMessage(incomingMessage)
        }
    }
    
    func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
    }
    
    func insertMessage(_ message: ChatMessage) {
        chatHistory.append(message)
        DispatchQueue.main.async {
            self.messagesCollectionView.performBatchUpdates({
                
                self.messagesCollectionView.insertSections([self.chatHistory.count - 1])
                if self.chatHistory.count >= 2 {
                    self.messagesCollectionView.reloadSections([self.chatHistory.count - 2])
                    
                }
                
            }, completion: { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            })
        }
    }
    
    func getChatHistory() {
        if let currentUser = PFUser.current(), let receiver = contactedUser, let senderId = currentUser.objectId {
            NetworkManager.getChatHistory(myId: senderId, contactedId: receiver.receiverId, success: {response in
                self.chatHistory = response
                self.loadFirstMessages()
            }) { (error) in
                self.displayError(message: error)
            }
        }
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
        messagesCollectionView.backgroundColor = UIColor.white
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
    
    func configureMessageInputBar() {
        if #available(iOS 13.0, *) {
            messageInputBar.subviews.forEach { $0.backgroundColor = UIColor.systemBackground}
            messageInputBar.contentView.backgroundColor = UIColor.systemBackground
            messageInputBar.blurView.isHidden = true
            messageInputBar.bottomStackView.backgroundColor = UIColor.systemBackground
            messageInputBar.inputAccessoryView?.backgroundColor = UIColor.systemBackground
            messageInputBar.inputTextView.backgroundColor = UIColor.systemBackground
            messageInputBar.backgroundColor = UIColor.systemBackground
            messageInputBar.backgroundView.backgroundColor = UIColor.systemBackground
            messageInputBar.leftStackView.backgroundColor = UIColor.red
        } else {
            // Fallback on earlier versions
        }
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor =  UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 12, left: 20, bottom: 8, right: 36)
        messageInputBar.shouldAutoUpdateMaxTextViewHeight = false
        messageInputBar.maxTextViewHeight = 100
        messageInputBar.inputTextView.font = FontHelper.regular(16.0)
        messageInputBar.inputTextView.placeholder = ""
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
    
    
    func addProfilePhotoNavigationBar() {
        circleView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        circleView.layer.borderColor = UIColor.systemPink.cgColor
        circleView.layer.borderWidth = 2
        circleView.layer.cornerRadius = circleView.frame.width / 2
        // user image
        profileIV = UIImageView(frame: CGRect(x: 2, y: 2, width: 32, height: 32))
        profileIV.layer.cornerRadius = profileIV.frame.width / 2
        profileIV.layer.masksToBounds = true
        profileIV.contentMode = .scaleToFill
        profileIV.isUserInteractionEnabled = true
        if let imageUrl = contactedUser?.imageUrl, let name = contactedUser?.firstName {
            profileIV.kf.setImage(with: URL(string: imageUrl))
            title = name
        }
        circleView.isUserInteractionEnabled = true
        circleView.addSubview(profileIV)
        circleView.addSubview(nameView)
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: circleView)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return chatHistory[indexPath.section].senderId == chatHistory[indexPath.section - 1].senderId
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < chatHistory.count else { return false }
        return chatHistory[indexPath.section].senderId == chatHistory[indexPath.section + 1].senderId
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return true }
        return !chatHistory[indexPath.section - 1].sentDate.isInSameDay(date: chatHistory[indexPath.section].sentDate)
    }
    
    func isLastSectionVisible() -> Bool {
        guard !chatHistory.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: chatHistory.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        // TODO: .mention ekle
        case .hashtag, .address, .phoneNumber, .transitInformation:
            return [.foregroundColor: UIColor(red: 26/255, green: 16/255, blue: 171/255, alpha: 1)]
            //            if isFromCurrentSender(message: message) {
            //                return [.foregroundColor: UIColor.workplaceKocHubGray]
            //            } else {
            //                return [.foregroundColor: UIColor.workplaceKocHubGray]
        //            }
        case .custom:
            return [.foregroundColor: UIColor(red: 26/255, green: 16/255, blue: 171/255, alpha: 1), .underlineStyle: NSUnderlineStyle.single.rawValue]
        case .url:
            return [.foregroundColor: UIColor(red: 26/255, green: 16/255, blue: 171/255, alpha: 1), .underlineStyle: NSUnderlineStyle.single.rawValue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let emailExpr = try! NSRegularExpression(pattern: emailRegEx, options: [])
        return [.custom(emailExpr), .address, .phoneNumber, .date, .transitInformation, .hashtag, .url] // .mention -> bunu custom kendin yap
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 228/255, green: 233/255, blue: 252/255, alpha: 1) : UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
}

extension ChatViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 15
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 12 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? 12 : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return !isNextMessageSameSender(at: indexPath) ? 15 : 0
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return MockUser(senderId: contactedUser?.myId ?? "", displayName: "Murat")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chatHistory[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chatHistory.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: FontHelper.regular(10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
}

extension ChatViewController: MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.text = ""
        if let currentUser = PFUser.current(), let receiver = contactedUser, let senderId = currentUser.objectId {
            let receiverId = receiver.receiverId
            NetworkManager.sendTextMessage(messageText: text, senderId: senderId, receiverId: receiverId, success: { (success) in
                print(success)
                self.messageInputBar.sendButton.stopAnimating()
            }) { (error) in
                self.messageInputBar.sendButton.stopAnimating()
                self.displayError(message: error)
            }
        }
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
    var messageModel: ChatMessage!
    var sender: SenderType {
        return mockUser
    }
    var messageId: String
    var kind: MessageKind
    var mockUser: MockUser
    
    var message: String?
    var senderId: String?
    
    init(messageModel: ChatMessage) {
        self.messageModel = messageModel
        self.sentDate = messageModel.sentDate
        self.message = messageModel.body
        self.senderId = messageModel.senderId
        self.messageId = messageModel.messageId
        self.kind = .text(messageModel.body )
        let displayName = "Murat Turan"
        self.mockUser = MockUser(senderId: messageModel.senderId , displayName: displayName)
        
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
