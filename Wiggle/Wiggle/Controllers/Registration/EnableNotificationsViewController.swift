//
//  EnableNotificationsViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 21.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class EnableNotificationsViewController: UIViewController {

    @IBOutlet weak var enableButton: UIButton!
    
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
   
    @IBAction func enableNotificationsAction(_ sender: UIButton) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
        }
    }
    
}
