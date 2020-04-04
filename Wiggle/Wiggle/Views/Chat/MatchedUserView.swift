//
//  MatchedUserView.swift
//  Wiggle
//
//  Created by Murat Turan on 4.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

protocol MatchViewDelegate{
    func matchViewTapped(user: PFUser?)
}

class MatchedUserView: UIView  {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate: MatchViewDelegate?
    var data: PFUser?
    
    class func instanceFromNib() -> MatchedUserView {
        return UINib(nibName: MatchedUserView.reuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MatchedUserView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    
    func prepare() {
        
    }
    
    func prepare(with data: PFUser, delegate: MatchViewDelegate) {
        self.data = data
        imageView.changeBorderWidth(0)
        let imageUrl = data.getPhotoUrl()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: imageUrl ?? ""))
        let name = "\(data.getFirstName())"
        nameLabel.text = "\(name)"
        self.delegate = delegate
    }
    
    func prepareForMatchScreen() {
        nameLabel.isHidden = true
        imageView.addBorder(UIColor(hexString: "D9B372"), width: 2)
    }
    
    @IBAction func viewTapped(_ sender: Any) {
           delegate?.matchViewTapped(user: data)
        
    }
}

extension MatchedUserView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
}
