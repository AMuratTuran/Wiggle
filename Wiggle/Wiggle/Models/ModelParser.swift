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
    
    static func PFUserToWiggleCardModel(user : [PFUser]) -> [WiggleCardModel]{
        var wiggleCardModels = [WiggleCardModel]()
        user.forEach { user in
            if let objectId = user.objectId{
                let name = "\(user.getFirstName()) \(user.getLastName())"
                let wiggleCardModel = WiggleCardModel(profilePicture: user.getPhotoUrl() ?? "", nameSurname: name, location: "", distance: "", bio: user.getBio(), objectId : objectId)
                wiggleCardModels.append(wiggleCardModel)
            }
        }
        
        return wiggleCardModels
    }
    
}
