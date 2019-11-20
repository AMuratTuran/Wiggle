//
//  GetNameViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 20.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class GetNameViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func prepareViews() {
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        
        nameTextField.delegate = self
        lastnameTextField.delegate = self
        // cevirileri yap
    }
    @IBAction func continueAction(_ sender: Any) {
        let firstname = nameTextField.text
        let lastname = lastnameTextField.text
        WiggleUser.user?["firstName"] = firstname!
        moveToGetBioViewController(navigationController: self.navigationController ?? UINavigationController())
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
