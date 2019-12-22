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

class GetNameViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var nameRequiredText: UILabel!
    @IBOutlet weak var lastNameRequiredText: UILabel!
    
    let validator = Validator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        enableValidations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func enableValidations() {
        validator.registerField(nameTextField, errorLabel: nameRequiredText, rules: [RequiredRule()])
        validator.registerField(lastnameTextField, errorLabel: lastNameRequiredText,  rules: [RequiredRule()])
    }
    
    func prepareViews() {
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        
        nameTextField.delegate = self
        lastnameTextField.delegate = self
        // cevirileri yap
    }
    @IBAction func continueAction(_ sender: Any) {
        startAnimating(self.view, startAnimate: true)
        validator.validate(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        let firstname = nameTextField.text
        let lastname = lastnameTextField.text
        PFUser.current()?.setValue(firstname, forKey: "first_name")
        PFUser.current()?.setValue(lastname, forKey: "last_name")
        PFUser.current()?.saveInBackground(block: { (result, error) in
            self.startAnimating(self.view, startAnimate: false)
            if error != nil {
                self.displayError(message: error?.localizedDescription ?? "")
            }else {
                self.moveToGenderViewController(navigationController: self.navigationController ?? UINavigationController())
            }
        })
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (_, error) in errors {
            self.startAnimating(self.view, startAnimate: false)
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
        }
    }
}
