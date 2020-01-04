//
//  ModelParser.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 4.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation
import Parse

class ModelParser{
    
    static func PFUserToWiggleCardModel(user : PFUser) -> WiggleCardModel{
        let name = "\(user.getFirstName()) \(user.getLastName())"
        let wiggleCardModel = WiggleCardModel(profilePicture: user.getPhotoUrl(), nameSurname: name, location: "", distance: "", bio: user.getBio())
        return wiggleCardModel
    }
    
}
