//
//  AppConstants.swift
//  Wiggle
//
//  Created by Murat Turan on 21.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
struct AppConstants {
    
    static var objectId : String = ""
    static var location : PFGeoPoint = PFGeoPoint()
    static var gender : Int = 0
    static var distance : Int = 1000
    
    struct General {
        static let ApplicationName: String = "Wiggle"
    }
    struct ParseConstants {
        static let ApplicationId: String = "EfuNJeqL484fqElyGcCuiTBjNHalE2BhAP2LIv7s"
        static let ClientKey: String = "L22P6I1Hxd3WMf8QT0umoy1HRuQit97Zd5i5HCjG"
        static let Server: String = "https://parseapi.back4app.com/"
        static let LiveQueryServer: String = "wss://lyngl.back4app.io/"
    }
    
    struct Color {
        static let mainHeaderTitleColor: UIColor = UIColor(hexString: "191a2a")
        static let mainSubtitleColor: UIColor = UIColor(hexString: "797686")
        static let mainPinkColor: UIColor = UIColor.systemPink
    }
    
    struct UserDefaultsKeys {
        static let SessionToken: String = "ParseSessionToken"
    }
}
