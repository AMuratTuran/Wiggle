//
//  EnterVerificationCodeViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class EnterVerificationCodeViewController: UIViewController {
    
    @IBOutlet weak var smsCodeTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    var sentSMSCode:Int?
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    func prepareViews() {
        self.title = Localize.LoginSignup.SMSLoginTitle
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        if #available(iOS 12.0, *) {
            smsCodeTextField.textContentType = .oneTimeCode
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @IBAction func continueAction(_ sender: Any) {
        if verifySMSCode() {
            if let phoneNumber = phoneNumber {
                let request = PhoneAuthRequest(phoneNumber: phoneNumber)
                NetworkManager.auth(request, success: {
                    // move to next page
                    self.moveToGetNameViewController()
                }) { (error) in
                    print(error)
                }
            }
        }
    }
    
    func verifySMSCode() -> Bool {
        guard let sentSMSCode = sentSMSCode else {
            return false
        }
        if String(sentSMSCode) == smsCodeTextField.text {
            return true
        }else {
            return false
        }
    }
}

