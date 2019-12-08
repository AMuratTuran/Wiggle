//
//  ChatListCell.swift
//  Wiggle
//
//  Created by Murat Turan on 7.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Kingfisher

class ChatListCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageStackView: UIStackView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastMessageArrowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func prepareViews() {
        profileImageView.kf.setImage(with: URL(string: "http://lorempixel.com/400/400/people/\(Int.random(in: 1...10))"))
        profileImageView.cornerRadius(profileImageView.frame.height / 2)
    }
    
}
