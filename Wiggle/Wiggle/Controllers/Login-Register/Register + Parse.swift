//
//  Register + Parse.swift
//  Wiggle
//
//  Created by Murat Turan on 2.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import PopupDialog

class ParseRegisterViewController: RegisterViewController {
    
    override func register() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let user = PFUser()
        user.username = email
        user.password = password
        
        user.signUpInBackground { (result, error) in
            if let error = error {
                self.startAnimating(self.view, startAnimate: false)
                let loginButton = DefaultButton(title: Localize.LoginSignup.LoginButton) {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                if error.localizedDescription.contains("already exists") {
                    self.alertMessage(message: error.localizedDescription, buttons: [loginButton], isErrorMessage: true)
                }else {
                    self.alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
                }
                return
            }
            
            if result {
                self.login()
            }
        }
    }
    
    func login() {
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
            
            self.moveToGetNameViewController()
        }
    }
}

