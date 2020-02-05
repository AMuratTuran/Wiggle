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
    let addButton = InputBarButtonItem(type: .infoDark)
    var chatHistory: [ChatMessage] = []
    var subscription: Subscription<PFObject>?
    var liveQueryClient: ParseLiveQuery.Client = ParseLiveQuery.Client(server: AppConstants.ParseConstants.LiveQueryServer, applicationId: AppConstants.ParseConstants.ApplicationId, clientKey: AppConstants.ParseConstants.ClientKey)
    let query1 = PFQuery(className:"Messages")
    let query2 = PFQuery(className:"Messages")
    var query: PFQuery<PFObject>!
    
    var imagePicker: ImagePicker!
    var isScrolled: Bool = false
    var skipCount: Int = 0
    
    var safariProtocol: SafariDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = PFUser.current() else {
            return
            // navigate to login
        }
        hideBackBarButtonTitle()
        self.currentUser = currentUser
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        safariProtocol = SafariManager(viewController: self)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(moreAction))
        } else {
            // Fallback on earlier versions
        }
        self.navigationItem.backBarButtonItem?.title = ""
        addProfilePhotoNavigationBar()
        configureMessageCollectionView()
        configureMessageCollectionViewLayout()
        getChatHistory(skipCount: skipCount)
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        liveQueryClient.unsubscribe(query)
    }
    
    
    func listenMessages(onCompelete: (()->())? = nil){
        guard let contactedUser = contactedUser else { return }
        
        query1.whereKey("sender", equalTo: contactedUser.myId)
        query1.whereKey("receiver", equalTo: contactedUser.receiverId)
        
        query2.whereKey("sender", equalTo: contactedUser.receiverId)
        query2.whereKey("receiver", equalTo: contactedUser.myId)
        
        query = PFQuery.orQuery(withSubqueries: [query1, query2])
        query.addAscendingOrder("createdAt")
        query.limit = 50
        

        subscription = liveQueryClient.subscribe(query)
        _ = subscription?.handle(Event.created) { (_, response) in
            if response["sender"] as! String != contactedUser.myId {
                response.setValue(1, forKey: "isRead")
                response.saveInBackground()
            }else {
                response.setValue(0, forKey: "isRead")
                response.saveInBackground()
            }
            let incomingMessage:ChatMessage = ChatMessage(dictionary: response)
            self.insertMessage(incomingMessage)
        }
        if let complete = onCompelete {
            complete()
        }
    }
    
    func loadFirstMessages() {
        if skipCount >= chatHistory.count {
            isScrolled = false
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if self.skipCount < 1 {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                } else {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
                self.skipCount = self.chatHistory.count
                self.isScrolled = false
            }
        }
    }
    
    func insertMessage(_ message: ChatMessage) {
        chatHistory.append(message)
        skipCount = chatHistory.count
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
    
    func getChatHistory(skipCount: Int) {
        if let currentUser = PFUser.current(), let receiver = contactedUser, let senderId = currentUser.objectId {
            NetworkManager.getChatHistory(myId: senderId, contactedId: receiver.receiverId, skipCount: skipCount, success: {response in
                if self.chatHistory.isEmpty {
                    self.chatHistory = response
                }else {
                    self.chatHistory.insert(contentsOf: response, at: 0)
                }
                self.loadFirstMessages()
            }) { (error) in
                self.displayError(message: error)
            }
        }
    }
    
    func configureMessageCollectionView() {
        configureMessageCollectionViewLayout()
        scrollsToBottomOnKeyboardBeginsEditing = true
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
        messageInputBar.setLeftStackViewWidthConstant(to: 38, animated: false)
        messageInputBar.setStackViewItems([addButton, InputBarButtonItem.fixedSpace(2)], forStack: .left, animated: false)
        addButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        addButton.setSize(CGSize(width: 36, height: 36), animated: false)
        addButton.title = nil
        addButton.imageView?.layer.cornerRadius = 16
        addButton.backgroundColor = .clear
        addButton.imageView?.backgroundColor = .systemPink
        addButton.tintColor = .systemPink
        addButton.image = UIImage(named: "add")
        addButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor =  UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 12, left: 20, bottom: 8, right: 36)
        messageInputBar.shouldAutoUpdateMaxTextViewHeight = false
        messageInputBar.inputTextView.textColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
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
    
    @objc func addImageTapped() {
        imagePicker.present(from: self.view)
    }
    
    @objc func moreAction() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: Localize.Chat.Report, style: .default) { (action) in
            if let contactedUser = self.contactedUser {
                let name = "\(contactedUser.firstName) \(contactedUser.lastName)"
                self.sendEmail(mail: "report@appwiggle.com", with: "Report User: \(name)")
            }
        }
        let unmatchAction = UIAlertAction(title: Localize.Chat.Unmatch, style: .default) { (action) in
            
        }
        let cancelAction = UIAlertAction(title: Localize.Common.CancelButton, style: .cancel) { (action) in
            
        }
        alertController.addAction(unmatchAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
        
        if inputBar.inputTextView.images.isEmpty {
            if let currentUser = PFUser.current(), let receiver = contactedUser, let senderId = currentUser.objectId {
                let receiverId = receiver.receiverId
                NetworkManager.sendTextMessage(messageText: text, senderId: senderId, receiverId: receiverId, success: { (success) in
                    self.messageInputBar.sendButton.stopAnimating()
                }) { (error) in
                    self.messageInputBar.sendButton.stopAnimating()
                    self.displayError(message: error)
                }
            }
        }else {
            if let currentUser = PFUser.current(), let receiver = contactedUser, let senderId = currentUser.objectId {
                let receiverId = receiver.receiverId
                guard let selectedImage = inputBar.inputTextView.images.first else { return }
                do {
                    guard let imageData = selectedImage.jpeg(.medium) else { return }
                    
                    NetworkManager.sendImageMessage(image: imageData, senderId: senderId, receiverId: receiverId, success: { (success) in
                        self.messageInputBar.sendButton.stopAnimating()
                    }) { (error) in
                        self.messageInputBar.sendButton.stopAnimating()
                        self.displayError(message: error)
                    }
                }
            }
        }
        messageInputBar.inputTextView.text = ""
        
    }
}


extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = chatHistory[indexPath.section]
            
            switch message.kind {
            case .photo( _):
                messageInputBar.inputTextView.resignFirstResponder()
                let imageView = FullScreenImageView.instanceFromNib()
                if let window = UIApplication.shared.keyWindow, let contactedUser = contactedUser {
                    imageView.prepare(with: message, contactedUser: contactedUser, frame: window.bounds)
                    imageView.delegate = self
                    messageInputBar.isHidden = true
                    window.addSubview(imageView)
                }
            default:
                break
            }
        }
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

extension ChatViewController: MessageLabelDelegate {
    func didSelectURL(_ url: URL) {
        let checkmailorurl = url.absoluteString
        if checkmailorurl.contains("mailto:") {
            let mail = checkmailorurl.replacingOccurrences(of: "mailto:", with: "")
            sendEmail(mail: mail)
        } else {
            safariProtocol?.presentSafari(urlString: url.absoluteString)
        }
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("phone selected")
        callPhone(phoneNumber: phoneNumber)
    }
    
    func didSelectDate(_ date: Date) {
        print("date selected")
        gotoAppleCalendar(date: date)
    }
    
    func didSelectCustom(_ pattern: String, match: String?) {
        print("custom selected")
        guard let mail = match else { return }
        if mail.isValidEmail() {
            sendEmail(mail: mail)
        }
    }
    
    func callPhone(phoneNumber: String) {
        guard let phoneUrl = URL(string: "tel://\(phoneNumber.removeIllegalCharacter())") else { return }
        UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
    }
    
    func gotoAppleCalendar(date: Date) {
        let alert = UIAlertController(title: "Ajanda", message: "Seçtiğiniz tarih ajanda da açılacaktır.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Tamam", style: .default) { _ in
            let interval = date.timeIntervalSinceReferenceDate
            let url = URL(string: "calshow:\(interval)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Vazgec", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendEmail(mail: String, with subject: String = "") {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients([mail])
        mailViewController.setMessageBody("", isHTML: false)
        mailViewController.setSubject(subject)
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        present(mailViewController, animated: true, completion: nil)
    }
}

struct MockUser: SenderType {
    var senderId: String
    var displayName: String
}

extension ChatViewController {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y < 100 && !isScrolled {
            isScrolled = true
            getChatHistory(skipCount: skipCount)
        }
    }
}

extension ChatViewController: UITextViewDelegate {
    
}

extension ChatViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else { return }
        
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let destinationViewController = storyBoard.instantiateViewController(withIdentifier: "SendImageViewController") as! SendImageViewController
        destinationViewController.pickedImage = image
        destinationViewController.delegate = self
        destinationViewController.modalPresentationStyle = .fullScreen
        destinationViewController.name = "\(contactedUser?.firstName ?? "") \(contactedUser?.lastName ?? "")"
        self.present(destinationViewController, animated: true, completion: nil)
    }
}

extension ChatViewController: ImageMessageProtocol {
    func imageConfirmed(image: UIImage) {
        startAnimating(self.view, startAnimate: true)
        if let currentUser = PFUser.current(), let receiver = contactedUser, let senderId = currentUser.objectId {
            let receiverId = receiver.receiverId
            do {
                guard let imageData = image.jpeg(.medium) else { return }
                listenMessages {
                    NetworkManager.sendImageMessage(image: imageData, senderId: senderId, receiverId: receiverId, success: { (success) in
                        self.startAnimating(self.view, startAnimate: false)
                        self.messageInputBar.sendButton.stopAnimating()
                    }) { (error) in
                        self.startAnimating(self.view, startAnimate: false)
                        self.messageInputBar.sendButton.stopAnimating()
                        self.displayError(message: error)
                    }
                }
            }
        }
    }
    
    func selectionCancelled() {
        listenMessages(onCompelete: nil)
    }
}

extension ChatViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController: FullScreenImageDelegate {
    func shouldRemoveFromWindow(view: UIView) {
        if let window = UIApplication.shared.keyWindow {
            messageInputBar.isHidden = false
            UIView.animate(withDuration: 0.2,animations: {
                view.alpha = 0
            }) { (isSuccess) in
                view.removeFromSuperview()
            }
        }
    }
}
