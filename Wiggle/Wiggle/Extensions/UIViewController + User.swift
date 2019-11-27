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
        return self.object(forKey: "firstName") as! String
    }
    
    func getLastName() -> String {
        return self.object(forKey: "lastName") as! String
    }
    
    func getBio() -> String {
        return self.object(forKey: "bio") as! String
    }
    
    func getBirthday() -> NSDate {
        return self.object(forKey: "birthday") as! NSDate
    }
    
    func getGold() -> Bool {
        return self.object(forKey: "gold") as! Bool
    }
    
    func getLocation() -> CLLocationCoordinate2D{
        return self.object(forKey: "gold") as! CLLocationCoordinate2D
    }
    
    func getGender() -> Int {
        return self.object(forKey: "gender") as! Int
    }
    
    
}
