//
//  WiggleCard.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 20.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

public class WiggleCardView : UIView{
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameSurname: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var bio: UILabel!
}

public struct WiggleCardModel{
    public var profilePicture : String?
    public var nameSurname : String?
    public var location : String?
    public var distance : String?
    public var bio : String?
    
    public init(profilePicture : String, nameSurname : String, location : String, distance : String, bio : String){
        self.profilePicture = profilePicture
        self.nameSurname = nameSurname
        self.location = location
        self.distance = distance
        self.bio = bio
    }
    public init(){}
}

class WiggleCard: WiggleCardComponent {
    
    public weak var view: WiggleCardView!
    
    public var model : WiggleCardModel?{
        didSet{
            updateUI()
        }
    }
    
    override public func componentDidLoad() {
        if let componentView = super.componentView as? WiggleCardView {
            view = componentView
        }
    }
    
    public func updateUI(){
        view.cornerRadius(12)
        view.profilePicture.cornerRadius(12)
        guard let model = model else {return}
        view.profilePicture.image = UIImage(named: model.profilePicture ?? "")
        view.nameSurname.text = model.nameSurname
        view.location.text = model.location
        view.distance.text = model.distance
        view.bio.text = model.bio
    }
    

}
