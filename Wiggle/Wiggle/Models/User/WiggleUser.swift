//
//  WiggleUser.swift
//  Wiggle
//
//  Created by Murat Turan on 20.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import Parse

public enum Gender: Int {
    case male = 1
    case female = 2
}

class WiggleUser {
    static var user = PFUser.current()
    
    var firstName: String = ""
    var lastName: String = ""
    var gender: Int = 0
    var birthDay: Date = Date()
    var bio: String = ""
//    var location: CLLocation = CLLocation()
//    var isEmailVerified: Bool = false
//    var authData: String = ""
//    var remote: Int = 0
//    var image: String = ""
//    var friends: [PFUser] = []
    
    init(dictionary: [String: Any]) {
        self.firstName = dictionary["first_name"] as? String ?? ""
        self.lastName = dictionary["last_name"] as? String ?? ""
        self.gender = dictionary["gender"] as? Int ?? 0
        self.birthDay = dictionary["birthDay"] as? Date ?? Date()
        self.bio = dictionary["bio"] as? String ?? ""
    }
}


