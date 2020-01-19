//
//  UITextField + Extensions.swift
//  Wiggle
//
//  Created by Murat Turan on 19.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

extension UITextField {

    func addInputAccessoryView() {
        self.inputAccessoryView = InputAccessoryView(field: self, resignFunc: {
            self.endEditing(true)
        }, clearFunc: nil)
    }
}
