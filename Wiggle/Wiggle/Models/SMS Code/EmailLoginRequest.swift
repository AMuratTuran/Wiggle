//
//  SMSCodeRequest.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation

struct EmailLoginRequest {
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func toDict() -> [String:String] {
        var dict: [String:String] = [:]
        
        dict.setIfNotNil("email", value: email)
        dict.setIfNotNil("password", value: password)
        
        return dict
    }
}
