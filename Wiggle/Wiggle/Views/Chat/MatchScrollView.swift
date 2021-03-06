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
        prepare(delegate: nil)
    }
    
    func prepare(delegate: MatchViewDelegate?) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let whoLikedView = MatchedUserView.instanceFromNib()
        whoLikedView.prepareForMatchScreen()
        if let delegate = delegate {
            whoLikedView.delegate = delegate
        }
        stackView.addArrangedSubview(whoLikedView)
    }
    
    func prepare(with data: [PFUser], delegate: MatchViewDelegate) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.isHidden = false
        let whoLikedView = MatchedUserView.instanceFromNib()
        whoLikedView.prepareForMatchScreen()
        whoLikedView.delegate = delegate
        stackView.addArrangedSubview(whoLikedView)
        
        data.forEach {
            let view = MatchedUserView.instanceFromNib()
            view.prepare(with: $0, delegate: delegate)
            stackView.addArrangedSubview(view)
        }
    }
}
