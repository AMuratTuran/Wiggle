//
//  NetworkManager.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import Parse

typealias JSON = [String: AnyObject]

protocol JsonInitializable {
    init (json: JSON) throws
}

struct NetworkManager {
    
    static func sendSMSCode(_ request: SMSCodeRequest, success: @escaping(Int) -> Void, fail: @escaping(String) -> Void) {
        PFCloud.callFunction(inBackground: "SendSMS", withParameters: request.toDict()) { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            guard let smsCode = response as? Int else {
                fail("Response cannot be nil")
                return
            }
            success(smsCode)
        }
    }
    
    static func auth(_ request: PhoneAuthRequest, success: @escaping() -> Void, fail: @escaping(String) -> Void) {
        PFCloud.callFunction(inBackground: "Auth", withParameters: request.toDict()) { (response, error) in
            if let error = error {
                fail(error.localizedDescription)
                return
            }
            guard let sessionToken = response as? String else {
                fail("Invalid Token")
                return
            }
            PFUser.become(inBackground: sessionToken) { (user, error) in
                if let error = error {
                    fail(error.localizedDescription)
                    return
                }
                guard let user = user else {
                    fail("No user data")
                    return
                }
                WiggleUser.user = user as! WiggleUser
                success()
            }
        }
    }
}
