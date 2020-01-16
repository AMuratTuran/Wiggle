//
//  SettingWithSliderCell.swift
//  Wiggle
//
//  Created by Murat Turan on 1.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class SettingWithSliderCell: UITableViewCell {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareCell(title: String) {
        titleLabel.text = title
        detailLabel.text = "\(Int(slider.value)) km"
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        let distance = Int(floor(sender.value))
        self.detailLabel.text = "\(distance) km"
        AppConstants.distance = distance
    }
}
