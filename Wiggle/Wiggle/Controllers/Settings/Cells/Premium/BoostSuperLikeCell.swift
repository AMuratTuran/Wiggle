//
//  BoostSuperLikeCell.swift
//  Wiggle
//
//  Created by Murat Turan on 1.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class BoostSuperLikeCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var boostImageContainer: UIView!
    @IBOutlet weak var boostContainerView: UIView!
    @IBOutlet weak var starImageContainer: UIView!
    @IBOutlet weak var superLikeContainerView: UIView!
    @IBOutlet weak var descBoostLabel: UILabel!
    @IBOutlet weak var descLikeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        prepare()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        boostImageContainer.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2, shadowOpacity: 0.3, shadowOffset:  CGSize(width: 0, height: 3))
        starImageContainer.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2, shadowOpacity: 0.3, shadowOffset:  CGSize(width: 0, height: 3))
        boostContainerView.addShadow()
        superLikeContainerView.addShadow()
    }
    func prepare() {
        boostContainerView.cornerRadius(12.0)
        superLikeContainerView.cornerRadius(12.0)
        descBoostLabel.text = Localize.SettingsPremium.GetBoost
        descLikeLabel.text = Localize.SettingsPremium.GetSuperLike
    }
    
}
