//
//  FullScreenImageView.swift
//  Wiggle
//
//  Created by Murat Turan on 23.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation
import Parse

protocol FullScreenImageDelegate {
    func shouldRemoveFromWindow(view: UIView)
}

class FullScreenImageView: UIView {
    
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var delegate: FullScreenImageDelegate?
    var areViewsHidden: Bool = false
    
    class func instanceFromNib() -> FullScreenImageView {
        return UINib(nibName: FullScreenImageView.reuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FullScreenImageView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    func prepare() {
        
    }
    
    func prepare(with data: ChatMessage, contactedUser: ChatListModel, frame: CGRect) {
        self.frame = frame
        imageView.image = data.imageData
        titleLabel.text = data.isReceived ? contactedUser.firstName : "You"
        subtitleLabel.text = data.sentDate.prettyStringFromDate(dateFormat: "dd.MM.yyyy HH:mm", localeIdentifier: Locale.current.identifier)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        delegate?.shouldRemoveFromWindow(view: self)
    }
    @IBAction func viewTapped(_ sender: Any) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor.systemBackground
            } else {
                // Fallback on earlier versions
            }
            self.imageView.backgroundColor = UIColor.lightGray
            if self.areViewsHidden {
                self.topView.isHidden = false
                self.bottomView.isHidden = false
            }else {
                self.backgroundColor = UIColor.black
                self.imageView.backgroundColor = UIColor.black
                self.topView.isHidden = true
                self.bottomView.isHidden = true
            }
            self.areViewsHidden = !self.areViewsHidden
        }
        
        
    }
    
}
