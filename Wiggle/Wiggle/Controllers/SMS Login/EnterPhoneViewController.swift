//
//  EnterPhoneViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import RLBAlertsPickers
import SwiftValidator
import PopupDialog

class EnterPhoneViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneRequiredText: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRequiredText: UILabel!
    
    let validator = Validator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        enableValidations()
        hideBackBarButtonTitle()
        self.title = Localize.LoginSignup.EmailLoginTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        continueButton.isUserInteractionEnabled = true
        passwordTextField.attributedPlaceholder = NSAttributedString(string: Localize.LoginSignup.PasswordTF, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        descriptionLabel.text = Localize.LoginSignup.EmailDesc
    }
    
    func enableValidations() {
        validator.registerField(emailTextField, errorLabel: phoneRequiredText, rules: [RequiredRule()])
        validator.registerField(passwordTextField, errorLabel: passwordRequiredText, rules: [RequiredRule(), MaxLengthRule(length: 50), MinLengthRule(length: 3)])
    }
    
    func prepareViews() {
        self.view.setGradientBackground()
        whiteAndTransparentLabelNavigationBar()
        continueButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        emailTextField.delegate = self
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        startAnimating(self.view, startAnimate: true)
        continueButton.isUserInteractionEnabled = false
        validator.validate(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func signupUser(request: EmailLoginRequest) {
        let user = PFUser()
        user.username = request.email
        user.password = request.password
        UserDefaults.standard.set(user.password, forKey: user.email ?? "")
        user.signUpInBackground { (result, error) in
            if let error = error {
                self.emailLogin()
            }
            if result {
                self.emailLogin()
            }
        }
    }
    
    func signup() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let user = PFUser()
        user.username = email
        user.password = password
        if email.isValidEmail() {
        user.signUpInBackground { (result, error) in
            self.startAnimating(self.view, startAnimate: false)
            if let error = error {
                if error.localizedDescription.contains("already exists") {
                    self.emailLogin()
                }else {
                    self.displayError(message: error.localizedDescription)
                }
            }
            if result {
                let okButton = DefaultButton(title: Localize.Common.OKButton) {
                    self.emailLogin()
                }
                self.alertMessage(message: Localize.LoginSignup.SignupSuccess, buttons: [okButton], isErrorMessage: false, isGestureDismissal: false)
            }
        }
        }else {
            self.startAnimating(self.view, startAnimate: false)
            continueButton.isUserInteractionEnabled = true
            self.displayError(message: Localize.LoginSignup.EmailValidError)
        }
    }
    
    func emailLogin() {
        self.startAnimating(self.view, startAnimate: true)
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let emailRequest = EmailLoginRequest(email: email, password: password)
        if email.isValidEmail() {
            NetworkManager.emailLogin(emailRequest, success: { (result) in
            self.continueButton.isUserInteractionEnabled = true
            self.startAnimating(self.view, startAnimate: false)
                if !result {
                    DispatchQueue.main.async {
                        self.moveToGetNameViewController()
                    }
                }else {
                    DispatchQueue.main.async {
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        delegate.initializeWindow()
                    }
                }
            }) { (error) in
                self.continueButton.isUserInteractionEnabled = true
                self.startAnimating(self.view, startAnimate: false)
                self.displayError(message: error)
            }
        }else {
            self.continueButton.isUserInteractionEnabled = true
            self.startAnimating(self.view, startAnimate: false)
            self.displayError(message: Localize.LoginSignup.EmailValidError)
        }
    }
    
    @IBAction func pickPhoneCode(_ sender: UIButton) {
        let alert = UIAlertController(style: .actionSheet, title: Localize.Common.PhoneCodes)
        alert.addLocalePicker(type: .phoneCode) { info in
            sender.setTitle(info?.phoneCode, for: .normal)
        }
        alert.addAction(title: Localize.Common.OKButton, style: .cancel)
        alert.show()
    }
}

extension EnterPhoneViewController: ValidationDelegate {
    func validationSuccessful() {
        phoneRequiredText.isHidden = true
        passwordRequiredText.isHidden = true
        signup()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        startAnimating(self.view, startAnimate: false)
        continueButton.isUserInteractionEnabled = true
        for (_, error) in errors {
          error.errorLabel?.text = error.errorMessage
          error.errorLabel?.isHidden = false
        }
    }
}

extension EnterPhoneViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        phoneRequiredText.isHidden = true
        passwordRequiredText.isHidden = true
    }
}
    

