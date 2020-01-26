//
//  EditProfileViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import SwiftValidator

protocol UpdateInfoDelegate {
    func infosUpdated()
}

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioTitleLabel: UILabel!
    @IBOutlet weak var pickBirthdayButton: UIButton!
    
    var birthday: Date?
    let nameTextFieldView = TextFieldView.load(title: "", placeholder: "")
    let lastnameTextFieldView = TextFieldView.load(title: "", placeholder: "")
    let validator = Validator()
    var delegate: UpdateInfoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
    }
    
    func configureViews() {
        guard let user = PFUser.current() else {
            return
        }
        
        self.imageBackgroundView.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
        let imageUrl = user.getPhotoUrl()
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: URL(string: imageUrl))
        
        nameTextFieldView.text = user.getFirstName()
        nameStackView.addArrangedSubview(nameTextFieldView)
        lastnameTextFieldView.text = user.getLastName()
        nameStackView.addArrangedSubview(lastnameTextFieldView)
        prepareForValidation()
        
        bioTextView.layer.borderColor = UIColor.systemGray.cgColor
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.cornerRadius = 12.0
        bioTextView.text = user.getBio()
        bioTextView.inputAccessoryView = InputAccessoryView(field: bioTextView, resignFunc: {
            self.bioTextView.endEditing(true)
        }, clearFunc: nil)
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        pickBirthdayButton.setTitle((user.getBirthday() as Date).prettyStringFromDate(dateFormat: "dd MMMM yyyy", localeIdentifier: "tr"),  for: .normal)
        birthday = user.getBirthday() as Date
    }
    
    func configureNavigationBar() {
        title = "Bilgileri Düzenle"
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveInfos))
        saveButton.tintColor = UIColor.systemPink
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func prepareForValidation() {
        nameTextFieldView.prepareValidation(validator: self.validator, validationRules: [RequiredRule(message: Localize.Common.Required)])
        lastnameTextFieldView.prepareValidation(validator: self.validator, validationRules: [RequiredRule(message: Localize.Common.Required)])
    }
    
    @objc func saveInfos() {
        self.startAnimating(self.view, startAnimate: true)
        validator.validate(self)
    }
    
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func pickBirthdayAction(_ sender: Any) {
        let calendar = Calendar(identifier: .gregorian)
        
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = -18
        components.month = 0
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -100
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        guard let user = PFUser.current() else {
            return
        }
        let startDate = user.getBirthday() as Date
        
        let alert = UIAlertController(style: .actionSheet, title: Localize.DatePicker.PickDate)
        
        alert.addDatePicker(mode: .date, date: startDate, minimumDate: minDate, maximumDate: maxDate) { date in
            self.birthday = date.adding(.hour, value: 3)
            self.pickBirthdayButton.setTitle(date.dateString(), for: .normal)
        }
        alert.addAction(title: Localize.Common.OKButton, style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

extension EditProfileViewController: ValidationDelegate {
    func validationSuccessful() {
        let name = nameTextFieldView.text
        let lastname = lastnameTextFieldView.text
        let bio = bioTextView.text
        
        PFUser.current()?.setValue(name, forKey: "first_name")
        PFUser.current()?.setValue(lastname, forKey: "last_name")
        PFUser.current()?.setValue(bio, forKey: "bio")
        PFUser.current()?.setValue(birthday, forKey: "birthday")
        PFUser.current()?.saveInBackground(block: { (result, error) in
            self.startAnimating(self.view, startAnimate: false)
            if error != nil {
                self.displayError(message: error?.localizedDescription ?? "")
            }else {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.infosUpdated()
            }
        })
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        self.startAnimating(self.view, startAnimate: false)
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }
}
