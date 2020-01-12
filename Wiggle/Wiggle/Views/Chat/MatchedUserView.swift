//
//  MatchedUserView.swift
//  Wiggle
//
//  Created by Murat Turan on 4.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class MatchedUserView: UIView {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    class func instanceFromNib() -> MatchedUserView {
        return UINib(nibName: MatchedUserView.reuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MatchedUserView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    
    func prepare() {
        
    }
}
