//
//  FontHelper.swift
//  Wiggle
//
//  Created by Murat Turan on 19.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import UIKit

class FontHelper {
    
    static func regular(_ size: CGFloat = 14) -> UIFont {
        if let font = UIFont(name: "OpenSans-Regular", size: size) {
            return font
        }
        
        
        return UIFont.systemFont(ofSize: size)
    }
    
    static func bold(_ size: CGFloat = 14) -> UIFont {
        if let font = UIFont(name: "OpenSans-Bold", size: size) {
            return font.boldType
        }
        return UIFont.boldSystemFont(ofSize: size)
    }
    
    static func medium(_ size: CGFloat = 14) -> UIFont {
        if let font = UIFont(name: "OpenSans-SemiBold", size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
    
    static func light(_ size: CGFloat = 14) -> UIFont {
        if let font = UIFont(name: "Ubuntu-Light", size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
}

extension UIFont {

    var boldType: UIFont {
        return withWeight(.bold)
    }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
