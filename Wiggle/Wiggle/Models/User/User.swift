//
//  User.swift
//  Wiggle
//
//  Created by Murat Turan on 4.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation
import Parse

class User: JsonInitializable {
    static var current: User?
    
    var objectId: String
    var firstName: String
    var lastName: String
    var gender: Int
    var bio: String
    var birthday: Date
    var image: String?
    var longitude: Double?
    var latitude: Double?
    var age: Int?
    var isLiked: Bool = false
    var trend: Date?
    var boostCount: Int = 0
    
    init(objectId: String, firstName: String, lastName: String, gender: Int, bio: String, birthdate: Date, image: String, longitude: Double?, latitude: Double?) {
        self.objectId = objectId
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.bio = bio
        self.birthday = birthdate
        self.image = image
        self.longitude = longitude
        self.latitude = latitude
    }
    
    init(parseUser: PFUser) {
        self.objectId = parseUser.objectId ?? ""
        self.firstName = parseUser.getFirstName()
        self.lastName = parseUser.getLastName()
        self.gender = parseUser.getGender()
        self.bio = parseUser.getBio()
        self.birthday = parseUser.getBirthday() as! Date
        self.image = parseUser.getPhotoUrl()
        self.longitude = parseUser.getLocation().longitude
        self.latitude = parseUser.getLocation().latitude
        self.age = parseUser.getAge()
        if let trend = parseUser.object(forKey: "trend") as? Date {
            self.trend = trend
        }
        if let boostCount = parseUser.object(forKey: "boost") as? Int {
            self.boostCount = boostCount
        }
    }
    
    required init(json: JSON) throws {
        objectId = try json.get("objectId") 
        firstName = try json.get("firstName")
        lastName = try json.get("lastName")
        gender = try json.get("gender")
        bio = try json.getOptional("bio") ?? ""
        birthday = try json.get("birthday")
        image = try json.getOptional("image")
        longitude = try json.getOptional("longitude") ?? 0.0
        latitude = try json.getOptional("latitude") ?? 0.0
        age = getAge(birthday: try json.get("birthday"))
    }
    
    func getAge(birthday: Date) -> Int {
        return 0
    }
}
