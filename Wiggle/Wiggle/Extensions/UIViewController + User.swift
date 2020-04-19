//
//  UIViewController + User.swift
//  Wiggle
//
//  Created by Murat Turan on 27.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

extension PFUser {
    
    func getFirstName() -> String {
        guard let lastName = self.object(forKey: "first_name") as? String else {return ""}
        return lastName
    }
    
    func getLastName() -> String {
        guard let lastName = self.object(forKey: "last_name") as? String else {return ""}
        return lastName
    }
    
    func getBio() -> String {
        guard let bio = self.object(forKey: "bio") as? String else {return ""}
        return bio
    }
    
    func getPhotoUrl() -> String? {
        guard let photo = self.object(forKey: "photo") as? PFFileObject else {return ""}
        return photo.url
    }
    
    func getBirthday() -> NSDate {
        guard let birthday = self.object(forKey: "birthday") as? NSDate else { return NSDate() }
        return birthday
    }
    
    func getGold() -> Bool {
        guard let gold = self.object(forKey: "isGold") as? Bool else {return false}
        return gold
    }
    
    func getLocation() -> CLLocationCoordinate2D{
        guard let parseLocation = self.object(forKey: "location") as? PFGeoPoint else {return CLLocationCoordinate2D()}
        let lat = parseLocation.latitude
        let lon = parseLocation.longitude
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func getRelation() -> PFRelation<PFUser>? {
        guard let relation = self.object(forKey: "friends") as? PFRelation<PFUser> else { return nil }
        return relation
    }
    
    func getGender() -> Int {
        guard let gender = self.object(forKey: "gender") as? Int else { return 0 }
        return gender
    }
    
    func getAge() -> Int {
        let now = Date()
        let birthday: Date = getBirthday() as Date
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let age = ageComponents.year!
        return age
    }
    
    func getUsername() -> String {
        guard let username = self.object(forKey: "username") as? String else {return ""}
        return username
    }
    
    func getAuthData() -> PFObject? {
        guard let authData = self.object(forKey: "authData") as? PFObject else { return nil }
        return authData
    }
    
    func isFacebookLogin() -> Bool {
        guard let username = self.object(forKey: "username") as? String else {return false}
        if username.count > 13 {
            return true
        }else {
            return false
        }
    }
    
    func getSuperLike() -> Int{
        guard let superlike = self.object(forKey: "super_like") as? Int else {return 0}
        return superlike
    }
    
    func getBoosts() -> Int{
        guard let boosts = self.object(forKey: "boost") as? Int else {return 0}
        return boosts
    }
}
