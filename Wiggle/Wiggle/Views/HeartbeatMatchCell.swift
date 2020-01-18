//
//  HeartbeatMatchCell.swift
//  Wiggle
//
//  Created by Murat Turan on 16.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class HeartbeatMatchCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    
    func prepare() {
        
    }
    
    func prepare(with data: PFUser) {
        let imageUrl = data.getPhotoUrl()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: imageUrl))
        let age = "\(data.getAge())"
        let name = "\(data.getFirstName()) \(data.getLastName())"
        nameAndAgeLabel.text = "\(name), \(age)"
        locationLabel.text = "4 km uzakta"
    }
}
