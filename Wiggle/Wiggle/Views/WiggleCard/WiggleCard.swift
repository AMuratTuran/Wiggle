//
//  WiggleCard.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 20.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Kingfisher

public class WiggleCardView : UIView{
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameSurname: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var dislikeImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    public override func awakeFromNib() {

    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 13.0, *) {
            backView.addBorder(UIColor.label, width: 0.1)
        } else {
            backView.addBorder(UIColor.black, width: 0.1)
        }
    }
}

public struct WiggleCardModel{
    public var profilePicture : String?
    public var nameSurname : String?
    public var location : String?
    public var distance : String?
    public var bio : String?
    public var objectId : String?
    
    public init(profilePicture : String, nameSurname : String, location : String, distance : String, bio : String, objectId : String){
        self.profilePicture = profilePicture
        self.nameSurname = nameSurname
        self.location = location
        self.distance = distance
        self.bio = bio
        self.objectId = objectId
    }
    public init(){}
}

class WiggleCard: WiggleCardComponent {
    
    public weak var view: WiggleCardView!
    
    public var model : WiggleCardModel?
    
    override public func componentDidLoad() {
        if let componentView = super.componentView as? WiggleCardView {
            view = componentView
        }
    }
    
    public func updateUI(){
        view.cornerRadius(12)
        view.backView.cornerRadius(12)
        view.likeImage.alpha = 0.0
        view.dislikeImage.alpha = 0.0
        guard let model = model else {return}
        if let photoUrl = model.profilePicture{
            if !photoUrl.isEmpty{
                view.profilePicture.kf.setImage(with: URL(string: photoUrl))
            }else{
                view.profilePicture.image = UIImage(named: "profilePicture")
            }
        }else{
            view.profilePicture.image = UIImage(named: "profilePicture")
        }
        view.nameSurname.text = model.nameSurname
        view.location.text = model.location
        view.distance.text = model.distance
        view.bio.text = model.bio
        view.profilePicture.heroID = "fromHomeProfilePicture"
        view.nameSurname.heroID = "fromHomeName"
        view.bio.heroID = "fromHomeBio"
    }
}
