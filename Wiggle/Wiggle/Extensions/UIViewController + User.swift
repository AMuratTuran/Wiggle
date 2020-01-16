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
    
    func getPhotoUrl() -> String{
        guard let photo = self.object(forKey: "photo") as? PFFileObject else {return ""}
        return photo.url ?? ""
    }
    
    func getBirthday() -> NSDate {
        guard let birthday = self.object(forKey: "birthday") as? NSDate else {return NSDate()}
        return birthday
    }
    
    func getGold() -> Bool {
        guard let gold = self.object(forKey: "gold") as? Bool else {return false}
        return gold
    }
    
    func getLocation() -> CLLocationCoordinate2D{
        guard let location = self.object(forKey: "location") as? CLLocationCoordinate2D else {return CLLocationCoordinate2D()}
        return location
    }
    
    func getGender() -> Int {
        guard let gender = self.object(forKey: "gender") as? Int else {return 1}
        return gender
    }
    
    func getAge() -> Int {
        let now = Date()
        let birthday: Date = getBirthday() as! Date
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let age = ageComponents.year!
        return age
    }
    
    
}
