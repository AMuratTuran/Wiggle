//
//  UIView + ReuseIdentifier .swift
//  Wiggle
//
//  Created by Murat Turan on 7.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

protocol ReuseIdentifying {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UIView: ReuseIdentifying {}
