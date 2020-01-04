//
//  MatchScrollView.swift
//  Wiggle
//
//  Created by Murat Turan on 4.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class MatchScrollView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    
    class func instanceFromNib() -> MatchScrollView {
        return UINib(nibName: MatchScrollView.reuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MatchScrollView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    
    func prepare() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let view1 = MatchedUserView.instanceFromNib()
        let view2 = MatchedUserView.instanceFromNib()
        let view3 = MatchedUserView.instanceFromNib()
        let view4 = MatchedUserView.instanceFromNib()
        let view5 = MatchedUserView.instanceFromNib()
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        stackView.addArrangedSubview(view3)
        stackView.addArrangedSubview(view4)
        stackView.addArrangedSubview(view5)
    }
}
