//
//  SettingsPremiumTableViewCell.swift
//  Wiggle
//
//  Created by Murat Turan on 22.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

enum MembershipType: String {
    case gold = "Wiggle Gold"
    case plus = "Wiggle Plus"
}

class SettingsPremiumTableViewCell: UITableViewCell {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var rightFlame: UIImageView!
    @IBOutlet weak var leftFlame: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        if #available(iOS 13.0, *) {
            self.containerView.addShadow()
        } else {
            // Fallback on earlier versions
        }
    }

    func prepare(type: MembershipType) {
        switch type {
        case .gold:
            rightFlame.tintColor = UIColor.systemOrange
            leftFlame.tintColor = UIColor.systemOrange
        case .plus:
            rightFlame.tintColor = UIColor.systemRed
            leftFlame.tintColor = UIColor.systemRed
        }
    }
    
}
