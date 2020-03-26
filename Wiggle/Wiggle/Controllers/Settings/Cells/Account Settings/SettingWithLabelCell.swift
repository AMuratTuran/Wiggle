//
//  SettingWithLabelCell.swift
//  Wiggle
//
//  Created by Murat Turan on 1.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class SettingWithLabelCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.setCustomSpacing(4, after: detailLabel)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func prepare() {
        if let user = PFUser.current(), let _ = user["authData"] as? [String:AnyObject] {
            titleLabel.text = "Facebook Profile"
            detailLabel.text = "\(user.getFirstName()) \(user.getLastName())"
        }
    }
    
    func prepareCell(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
        arrowImage.isHidden = false
    }
}
