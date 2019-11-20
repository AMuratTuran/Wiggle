//
//  SMSCodeRequest.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation

struct SMSCodeRequest {
    var countryCode: String
    var phoneNumber: String
    
    init(countryCode: String, phoneNumber: String) {
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }
    
    func toDict() -> [String:String] {
        var dict: [String:String] = [:]
        
        dict.setIfNotNil("country", value: countryCode)
        dict.setIfNotNil("phone", value: phoneNumber)
        
        return dict
    }
}
