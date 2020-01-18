//
//  MatchScrollView.swift
//  Wiggle
//
//  Created by Murat Turan on 4.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

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
    }
    
    func prepare(with data: [PFUser]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.isHidden = false
        if data.isEmpty {
            self.isHidden = true
        }
        data.forEach {
            let view = MatchedUserView.instanceFromNib()
            view.prepare(with: $0)
            stackView.addArrangedSubview(view)
        }
    }
}
