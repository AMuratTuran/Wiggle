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

class EnterPhoneViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var phoneCodePickerButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    var countryCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func prepareViews() {
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        let countryCode = Locale.current.regionCode
        if let countryCode = countryCode {
            let phoneCode = getCountryPhoneCode(countryCode)
            phoneCodePickerButton.setTitle(phoneCode, for: .normal)
            self.countryCode = phoneCode
        }
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        sendSMSCode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func sendSMSCode() {
        let currentUser = PFUser.current()
        if currentUser != nil {
            // Do stuff with the user
            PFUser.logOut()
            
        } else {
            // Show the signup or login screen
            let phoneNumber = phoneTextField.text!
            let smsCodeRequest = SMSCodeRequest(countryCode: self.countryCode, phoneNumber: phoneNumber)
            NetworkManager.sendSMSCode(smsCodeRequest, success: { (smsCode) in
                self.moveToEnterVerificationCodeViewController(smsCode: smsCode, phone: smsCodeRequest.phoneNumber)
            }) { (error) in
                print(error)
            }
        }
    }
    @IBAction func pickPhoneCode(_ sender: UIButton) {
        let alert = UIAlertController(style: .actionSheet, title: "Phone Codes")
        alert.addLocalePicker(type: .phoneCode) { info in
            sender.setTitle(info?.phoneCode, for: .normal)
            self.countryCode = info?.phoneCode ?? ""
        }
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
}
