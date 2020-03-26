//
//  UIColor + Extensions.swift
//  Wiggle
//
//  Created by Murat Turan on 27.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    @nonobjc class var goldenColor: UIColor {
        return UIColor(red: 217.0 / 255.0, green: 179.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var shadowColor: UIColor {
        return UIColor(hexString: "A2834D")
    }
    
}
