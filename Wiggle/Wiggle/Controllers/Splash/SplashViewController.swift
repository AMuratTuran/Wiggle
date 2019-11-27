//
//  SplashViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 27.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isLoggedIn() {
            
        }
    }
    
    func isLoggedIn() -> Bool {
        if PFUser.current() != nil {
            return true
        }else {
            return false
        }
    }
    
}
