//
//  UILabel + Extensions.swift
//  Wiggle
//
//  Created by Murat Turan on 19.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

extension UILabel {
    func errorStyle() {
        self.textColor = .red
        self.font = FontHelper.regular(10)
    }

    func warningStyle() {
        self.textColor = .orange
        self.font = FontHelper.regular(10)
    }
}

