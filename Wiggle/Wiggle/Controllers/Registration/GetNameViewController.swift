//
//  GetNameViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 20.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import SwiftValidator
import PopupDialog

class GetNameViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var nameRequiredText: UILabel!
    @IBOutlet weak var lastNameRequiredText: UILabel!
    
    let validator = Validator()
    var registerRequest = RegisterRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        enableValidations()
        if !UserDefaults.standard.bool(forKey: "TermsAccepted") {
            openTermsWebView()
        }
    }
    
    func enableValidations() {
        
        validator.registerField(nameTextField, errorLabel: nameRequiredText, rules: [RequiredRule()])
        validator.registerField(lastnameTextField, errorLabel: lastNameRequiredText,  rules: [RequiredRule()])
    }
    
    func prepareViews() {
        self.view.setGradientBackground()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        continueButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        
        topLabel.text = Localize.GetName.Title
        nameTextField.delegate = self
        nameTextField.attributedPlaceholder = NSAttributedString(string: Localize.Placeholder.FirstNamePlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        lastnameTextField.delegate = self
        lastnameTextField.attributedPlaceholder = NSAttributedString(string: Localize.Placeholder.LastNamePlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        if let user = PFUser.current() {
            let firstName = user.getFirstName()
            let lastName = user.getLastName()
            nameTextField.text = firstName
            lastnameTextField.text = lastName
        }
    }
    
    @IBAction func continueAction(_ sender: Any) {
        validator.validate(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func openTermsWebView() {
        let storyBoard = UIStoryboard(name: "WebView", bundle: nil)
        let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.isAcceptingTerms = true
        webViewController.delegate = self
        let nav = UINavigationController(rootViewController: webViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension GetNameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

extension GetNameViewController: ValidationDelegate {
    func validationSuccessful() {
        nameRequiredText.isHidden = true
        lastNameRequiredText.isHidden = true
        registerRequest.firstName = nameTextField.text ?? ""
        registerRequest.lastName = lastnameTextField.text ?? ""
        moveToGenderViewController(request: self.registerRequest)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
        }
    }
}

extension GetNameViewController: TermsViewDelegate {
    func acceptTapped() {
        
    }
    
    func declineTapped() {
        delay(1.0) {
            let okButton = DefaultButton(title: Localize.Common.OKButton, action: self.openTermsWebView)
            self.alertMessage(message: "You cannot continue using Wiggle without acceping Terms Of Use.", buttons: [okButton], isErrorMessage: true)
        }
    }
}
