//
//  LabelWithCheckmarkCell.swift
//  Wiggle
//
//  Created by Murat Turan on 1.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class LabelWithCheckmarkCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .none
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func prepareCell(title: String) {
        titleLabel.text = title
    }
    
}
