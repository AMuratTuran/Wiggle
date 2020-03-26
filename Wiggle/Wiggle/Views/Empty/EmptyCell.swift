//
//  EmptyCell.swift
//  Wiggle
//
//  Created by Murat Turan on 2.02.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var touchButton: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(icon: UIImage, description: String, isButtonVisible:Bool = false, buttonText: String, buttonColor: UIColor = UIColor(hexString: "D9B372"), buttonAction: (() -> Void)?) {
        iconImageView.image = icon
        descriptionLabel.text = description
        actionButton.isHidden = !isButtonVisible
        actionButton.setTitle(buttonText, for: .normal)
        actionButton.backgroundColor = buttonColor
        self.touchButton = buttonAction
    }
    @IBAction func actionButtonTapped(_ sender: Any) {
        touchButton?()
    }
}
