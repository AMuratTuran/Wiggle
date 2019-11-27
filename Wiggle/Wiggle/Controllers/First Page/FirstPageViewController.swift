//
//  FirstPageViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse

class FirstPageViewController: UIViewController {

    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    @IBOutlet weak var phoneLoginButton: UIButton!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptTermsLabel.text = Localize.LoginSignup.AcceptTerms
        facebookLoginButton.setTitle(Localize.LoginSignup.FacebookButton, for: .normal)
        phoneLoginButton.setTitle(Localize.LoginSignup.PhoneButton, for: .normal)
        facebookLoginButton.layer.cornerRadius = 12.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func facebookLoginTapped(_ sender: Any) {
        
        PFFacebookUtils.logInInBackground(withReadPermissions: nil) {
          (user: PFUser?, error: Error?) in
          if let user = user {
            if user.isNew {
              print("User signed up and logged in through Facebook!")
            } else {
              print("User logged in through Facebook!")
            }
          } else {
            print("Uh oh. The user cancelled the Facebook login.")
          }
        }
    }
    @IBAction func phoneLoginTapped(_ sender: Any) {
        if PFUser.current() != nil {
            PFUser.logOutInBackground { (error) in
                if error != nil {
                    self.displayError(message: "Lutfen tekrar deneyiniz.")
                }else {
                    self.moveToEnterPhoneViewController()
                }
            }
        }else {
            moveToEnterPhoneViewController()
        }
    }

}
