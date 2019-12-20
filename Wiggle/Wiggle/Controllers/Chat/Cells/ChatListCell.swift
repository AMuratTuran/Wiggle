//
//  ChatListCell.swift
//  Wiggle
//
//  Created by Murat Turan on 7.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Kingfisher
import Parse

class ChatListCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageStackView: UIStackView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastMessageArrowView: UIView!
    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var data: ChatListModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func prepareViews() {
        profileImageView.cornerRadius(profileImageView.frame.height / 2)
        lineHeight.constant = 0.5
    }
    
    func prepare(with data: ChatListModel) {
        self.data = data
        if let url = data.imageUrl {
            profileImageView.kf.setImage(with: URL(string: url))
        }
        nameLabel.text = data.receiverName
        lastMessageLabel.text = data.lastMessage
        dateLabel.text = data.dateString
        if data.isReceivedMessage {
            lastMessageArrowView.isHidden = false
        }else {
            lastMessageArrowView.isHidden = true
        }
    }
}
