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
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    func prepareViews() {
        topLabel.text = Localize.EnableNotifications.EnableNotification
        descriptionLabel.text = Localize.EnableNotifications.Description
        enableButton.setTitle(Localize.EnableNotifications.EnableButton, for: .normal)
    }
   
    @IBAction func enableNotificationsAction(_ sender: UIButton) {
        self.enableButton.isUserInteractionEnabled = false
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.enableButton.isUserInteractionEnabled = true
                UIApplication.shared.registerForRemoteNotifications()
                self.moveToHomeViewController(navigationController: self.navigationController ?? UINavigationController())
            }
        }
    }
}
