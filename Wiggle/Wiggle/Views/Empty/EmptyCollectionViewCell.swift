//
//  EmptyCollectionViewCell.swift
//  Wiggle
//
//  Created by Murat Turan on 5.02.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class EmptyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    var action: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepare(description: String) {
        descriptionLabel.text = description
        actionButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        if let action = self.action {
            action()
        }
    }
}
