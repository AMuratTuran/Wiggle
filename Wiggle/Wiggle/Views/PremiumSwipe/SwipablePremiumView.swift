//
//  SwipablePremiumView.swift
//  Wiggle
//
//  Created by Murat Turan on 18.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation

class SwipablePremiumView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    class func instanceFromNib() -> SwipablePremiumView {
        return UINib(nibName: SwipablePremiumView.reuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SwipablePremiumView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    
    func prepare() {
        
    }
    
    func prepare(title:String, subtitle: String)  {
        self.titleLabel.text = title
        self.descriptionLabel.text = subtitle
    }
}
