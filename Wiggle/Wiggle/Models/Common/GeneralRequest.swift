//
//  GeneralRequest.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation

struct GeneralRequest {
    var key: String
    var value: Any
    
    init(key: String, value: AnyObject) {
        self.key = key
        self.value = value
    }
}
