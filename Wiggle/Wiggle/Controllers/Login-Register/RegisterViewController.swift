//
//  RegisterViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 2.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import SwiftValidator
import PopupDialog

class RegisterViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailRequiredText: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRequiredText: UILabel!
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()

    }
    
    func initializeViews() {
        self.title = Localize.LoginSignup.RegisterButton
        setDefaultGradientBackground()
        hideBackBarButtonTitle()
        whiteAndTransparentLabelNavigationBar()
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: Localize.LoginSignup.PasswordTF, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        descriptionLabel.text = Localize.LoginSignup.EmailDesc
        
        registerButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        registerButton.setTitle(Localize.LoginSignup.RegisterButton, for: .normal)
        
        initializeValidations()
    }
    
    func initializeValidations() {
        validator.registerField(emailTextField, errorLabel: emailRequiredText, rules: [RequiredRule()])
        validator.registerField(passwordTextField, errorLabel: passwordRequiredText, rules: [RequiredRule(), MaxLengthRule(length: 50), MinLengthRule(length: 3)])
    }
    
    func register() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        startAnimating(self.view, startAnimate: true)
        validator.validate(self)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailRequiredText.isHidden = true
        passwordRequiredText.isHidden = true
    }
}

extension RegisterViewController: ValidationDelegate {
    func validationSuccessful() {
        emailRequiredText.isHidden = true
        passwordRequiredText.isHidden = true
        register()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        startAnimating(self.view, startAnimate: false)
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage.localizedCapitalized
          error.errorLabel?.isHidden = false
        }
    }
}
