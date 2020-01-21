//
//  TouchButton.swift
//  Wiggle
//
//  Created by Murat Turan on 20.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation

class TouchButton: UIButton {
    
    var view: UIView {
        get {
             self
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}
