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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepare(description: String) {
        descriptionLabel.text = description
    }
}
