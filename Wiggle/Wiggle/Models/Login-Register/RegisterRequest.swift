//
//  RegisterRequest.swift
//  Wiggle
//
//  Created by Murat Turan on 2.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation

class RegisterRequest: JsonConvertable {
    var firstName: String
    var lastName: String
    var gender: Int
    var bio: String
    var birthday: Date
    var image: NSData?
    var longtitude: Double?
    var latitude: Double?
    
    init(firstName: String, lastName: String, gender: Int, bio: String, birthdate: Date, image: NSData, longtitude: Double?, latitude: Double?) {
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.bio = bio
        self.birthday = birthdate
        self.image = image
        self.longtitude = longtitude
        self.latitude = latitude
    }
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.gender = 0
        self.bio = ""
        self.birthday = Date()
        self.image = nil
        self.longtitude = nil
        self.latitude = nil
    }
    
    func toJson() -> JSON {
        var dict: JSON = [:]
        
        dict.setIfNotNil("firstName", value: firstName)
        dict.setIfNotNil("lastName", value: lastName)
        dict.setIfNotNil("gender", value: gender)
        dict.setIfNotNil("bio", value: bio)
        dict.setIfNotNil("birthdate", value: birthday)
        dict.setIfNotNil("image", value: image)
        dict.setIfNotNil("longtitude", value: longtitude)
        dict.setIfNotNil("latitude", value: latitude)
        
        return dict
    }
}
