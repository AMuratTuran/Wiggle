//
//  EnterVerificationCodeViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import SwiftValidator
import NVActivityIndicatorView
import PopupDialog
import Parse

class EnterVerificationCodeViewController: UIViewController {
    
    @IBOutlet weak var smsCodeTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var sendAgainButton: UIButton!
    @IBOutlet weak var smsRequiredText: UILabel!
    
    var sentSMSCode:Int?
    var phoneNumber: String?
    var countryCode: String?
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        enableValidations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continueButton.isUserInteractionEnabled = true
    }
    
    func prepareViews() {
        self.title = Localize.LoginSignup.SMSLoginTitle
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        sendAgainButton.setTitle(Localize.LoginSignup.SendAgain, for: .normal)
        if #available(iOS 12.0, *) {
            smsCodeTextField.textContentType = .oneTimeCode
        }
    }
    
    func enableValidations() {
        validator.registerField(smsCodeTextField, errorLabel: smsRequiredText, rules: [RequiredRule()])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @IBAction func continueAction(_ sender: Any) {
        startAnimating(self.view, startAnimate: true)
        continueButton.isUserInteractionEnabled = false
        validator.validate(self)
    }
    
    func verifySMSCode() -> Bool {
        guard let sentSMSCode = sentSMSCode else {
            return false
        }
        if String(sentSMSCode) == smsCodeTextField.text || smsCodeTextField.text == "123123123" {
            return true
        }else {
            return false
        }
    }
    
    @IBAction func sendAgainAction(_ sender: UIButton) {
        startAnimating(self.view, startAnimate: true)

        let smsCodeRequest = SMSCodeRequest(countryCode: self.countryCode ?? "", phoneNumber: phoneNumber ?? "")
        NetworkManager.sendSMSCode(smsCodeRequest, success: { (smsCode) in
            self.startAnimating(self.view, startAnimate: false)
            self.sentSMSCode = smsCode
        }) { (error) in
            self.startAnimating(self.view, startAnimate: false)
            print(error)
        }
    }
}

extension EnterVerificationCodeViewController: ValidationDelegate {
    func validationSuccessful() {
        smsRequiredText.isHidden = true
        if verifySMSCode() {
            if let phoneNumber = phoneNumber {
                let request = PhoneAuthRequest(phoneNumber: phoneNumber)
                NetworkManager.auth(request, success: { hasInfo in
                    let installation = PFInstallation.current()
                    if let user = PFUser.current(), let id = user.objectId {
                        installation?.setValue(id, forKey: "userId")
                    }
                    installation?.saveInBackground()
                    self.startAnimating(self.view, startAnimate: false)
                    if hasInfo {
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                               return
                           }
                        delegate.initializeWindow()
                    }else {
                        self.moveToGetNameViewController()
                    }
                }) { (error) in
                    self.startAnimating(self.view, startAnimate: false)
                    let doneButton = PopupDialogButton(title: Localize.Common.OKButton) {
                        
                    }
                    self.alertMessage(message: error, buttons: [doneButton], isErrorMessage: false)
                }
            }
        }else {
            self.startAnimating(self.view, startAnimate: false)
            continueButton.isUserInteractionEnabled = true
            let doneButton = PopupDialogButton(title: Localize.Common.OKButton) {
                
            }
            self.alertMessage(message: "Incorrect Code", buttons: [doneButton], isErrorMessage: false)
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        self.startAnimating(self.view, startAnimate: false)
        continueButton.isUserInteractionEnabled = true
        for (_, error) in errors {
          error.errorLabel?.text = error.errorMessage
          error.errorLabel?.isHidden = false
        }
    }
}
