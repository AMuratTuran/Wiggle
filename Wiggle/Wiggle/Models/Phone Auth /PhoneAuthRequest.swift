//
//  PhoneAuthRequest.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation

struct PhoneAuthRequest {
   
    var phoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    func toDict() -> [String:String] {
        var dict: [String:String] = [:]
        
        dict.setIfNotNil("phone", value: phoneNumber)
        
        return dict
    }
}
