//
//  LogoutCell.swift
//  Wiggle
//
//  Created by Murat Turan on 8.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class LogoutCell: UITableViewCell {

    @IBOutlet weak var logoutLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareViews()
    }

    func prepareViews() {
        logoutLabel.text = Localize.Settings.Logout
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}