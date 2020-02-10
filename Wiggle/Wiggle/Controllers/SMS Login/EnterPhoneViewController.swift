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

class EnterPhoneViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var phoneCodePickerButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneRequiredText: UILabel!
    
    var countryCode: String = ""
    let validator = Validator()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        enableValidations()
        hideBackBarButtonTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        continueButton.isUserInteractionEnabled = true
    }
    
    func enableValidations() {
        validator.registerField(phoneTextField, errorLabel: phoneRequiredText, rules: [RequiredRule()])
    }
    
    func prepareViews() {
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        let countryCode = Locale.current.regionCode
        if let countryCode = countryCode {
            let phoneCode = getCountryPhoneCode(countryCode)
            phoneCodePickerButton.setTitle(phoneCode, for: .normal)
            self.countryCode = phoneCode
        }
        phoneTextField.delegate = self
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        startAnimating(self.view, startAnimate: true)
        continueButton.isUserInteractionEnabled = false
        validator.validate(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func sendSMSCode() {
        let phoneNumber = phoneTextField.text!
        let smsCodeRequest = SMSCodeRequest(countryCode: self.countryCode, phoneNumber: phoneNumber)
        NetworkManager.sendSMSCode(smsCodeRequest, success: { (smsCode) in
            self.startAnimating(self.view, startAnimate: false)
            self.moveToEnterVerificationCodeViewController(smsCode: smsCode, countryCode: self.countryCode, phone: smsCodeRequest.phoneNumber)
        }) { (error) in
            self.startAnimating(self.view, startAnimate: false)
        }
    }
    
    @IBAction func pickPhoneCode(_ sender: UIButton) {
        let alert = UIAlertController(style: .actionSheet, title: Localize.Common.PhoneCodes)
        alert.addLocalePicker(type: .phoneCode) { info in
            sender.setTitle(info?.phoneCode, for: .normal)
            self.countryCode = info?.phoneCode ?? ""
        }
        alert.addAction(title: Localize.Common.OKButton, style: .cancel)
        alert.show()
    }
}

extension EnterPhoneViewController: ValidationDelegate {
    func validationSuccessful() {
        phoneRequiredText.isHidden = true
        sendSMSCode()
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
    }
}
    

