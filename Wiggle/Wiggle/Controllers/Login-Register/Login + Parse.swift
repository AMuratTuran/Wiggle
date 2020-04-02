//
//  Login + Parse.swift
//  Wiggle
//
//  Created by Murat Turan on 2.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import PopupDialog

class ParseLoginViewController: LoginViewController {
    
    override func login() {
        let emailLoginRequest = EmailLoginRequest(email: emailTextField.text ?? "",
                                             password: passwordTextField.text ?? "")
        PFUser.logInWithUsername(inBackground: emailLoginRequest.email, password: emailLoginRequest.password) {(user, error) in
            self.startAnimating(self.view, startAnimate: false)
            if let error = error {
                self.alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
                return
            }
            guard let userInfo = user else { return }
            
            UserDefaults.standard.set(userInfo.sessionToken, forKey: AppConstants.UserDefaultsKeys.SessionToken)
            
            if let _ = userInfo["gender"] as? Int, let _ = userInfo["first_name"] as? String, let _ = userInfo["birthday"] as? Date {
                self.moveToRegisterViewController()
            }else {
                //anasayfaya yonlendir
            }
        }
    }
}
