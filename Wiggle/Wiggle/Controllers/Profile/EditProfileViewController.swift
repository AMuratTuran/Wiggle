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
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var secondImageDeleteButton: UIButton!
    @IBOutlet weak var thirdImageDeleteButton: UIButton!
    
    var birthday: Date?
    let nameTextFieldView = TextFieldView.load(title: "", placeholder: "")
    let lastnameTextFieldView = TextFieldView.load(title: "", placeholder: "")
    let validator = Validator()
    var delegate: UpdateInfoDelegate?
    var imagePicker: ImagePicker!
    var additionalImages: [PFObject]?
    
    var selectedSecondImage: UIImage?
    var selectedThirdImage: UIImage?
    var selectedImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
        getImages()
    }
    
    func configureViews() {
        guard let user = PFUser.current() else {
            return
        }
        self.view.setGradientBackground()
        transparentNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        self.imageBackgroundView.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
        let imageUrl = user.getPhotoUrl()
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: URL(string: imageUrl ?? ""))
        
        secondImageView.addBorder(UIColor.white.withAlphaComponent(0.5), width: 0.5)
        let secondImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSecondImage))
        secondImageView.addGestureRecognizer(secondImageRecognizer)
        secondImageView.isUserInteractionEnabled = true
        
        thirdImageView.addBorder(UIColor.white.withAlphaComponent(0.5), width: 0.5)
        let thirdImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapThirdImage))
        thirdImageView.addGestureRecognizer(thirdImageRecognizer)
        thirdImageView.isUserInteractionEnabled = true
        
        nameTextFieldView.getTextField().textColor = UIColor.white
        nameTextFieldView.text = user.getFirstName()
        nameStackView.addArrangedSubview(nameTextFieldView)
        
        lastnameTextFieldView.getTextField().textColor = UIColor.white
        lastnameTextFieldView.text = user.getLastName()
        nameStackView.addArrangedSubview(lastnameTextFieldView)
        prepareForValidation()
        
        bioTextView.delegate = self
        bioTextView.layer.borderColor = UIColor.systemGray.cgColor
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.cornerRadius = 12.0
        bioTextView.textColor = UIColor.white.withAlphaComponent(0.6)
        bioTextView.text = user.getBio()
        bioTextView.inputAccessoryView = InputAccessoryView(field: bioTextView, resignFunc: {
            self.bioTextView.endEditing(true)
        }, clearFunc: nil)
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        pickBirthdayButton.setTitle((user.getBirthday() as Date).prettyStringFromDate(dateFormat: "dd MMMM yyyy", localeIdentifier: Locale.current.identifier),  for: .normal)
        birthday = user.getBirthday() as Date?
        birthdayLabel.text = Localize.Profile.Birthday
    }
    
    @objc func didTapSecondImage() {
        selectedImageView = secondImageView
        self.imagePicker.present(from: secondImageView)
    }
    
    @objc func didTapThirdImage() {
        selectedImageView = thirdImageView
        self.imagePicker.present(from: thirdImageView)
    }
    
    func getImages() {
        if let userId = PFUser.current()?.objectId {
            NetworkManager.getImageObject(by: userId, success: { (response) in
                if !response.isEmpty {
                    self.additionalImages = response
                    if response.count == 1 , let imageData = response.first?.object(forKey: "photo") as? PFFileObject, let url = imageData.url {
                        self.secondImageView.kf.setImage(with: URL(string: url))
                        self.secondImageDeleteButton.isHidden = false
                        self.thirdImageDeleteButton.isHidden = true
                    }else if response.count == 2, let firstImageData = response.first?.object(forKey: "photo") as? PFFileObject, let secondImageData = response[1].object(forKey: "photo") as? PFFileObject{
                        let firstUrl = firstImageData.url ?? ""
                        let secondUrl = secondImageData.url ?? ""
                        self.secondImageView.kf.setImage(with: URL(string: firstUrl))
                        self.thirdImageView.kf.setImage(with: URL(string: secondUrl))
                        self.secondImageDeleteButton.isHidden = false
                        self.thirdImageDeleteButton.isHidden = false
                    }
                }else {
                    self.secondImageDeleteButton.isHidden = true
                    self.thirdImageDeleteButton.isHidden = true
                }
            }) { (error) in
                
            }
        }
    }
    
    func configureNavigationBar() {
        title = Localize.Profile.EditProfile
        
        let saveButton = UIBarButtonItem(title: Localize.Common.Save, style: .plain, target: self, action: #selector(saveInfos))
        saveButton.tintColor = UIColor.systemPink
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(title: Localize.Common.CancelButton, style: .plain, target: self, action: #selector(dismissTapped))
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
        let startDate = user.getBirthday()
        
        let alert = UIAlertController(style: .actionSheet, title: Localize.DatePicker.PickDate)
        
        alert.addDatePicker(mode: .date, date: startDate as Date?, minimumDate: minDate, maximumDate: maxDate) { date in
            self.birthday = date.adding(.hour, value: 3)
            self.pickBirthdayButton.setTitle(date.dateString(), for: .normal)
        }
        alert.addAction(title: Localize.Common.OKButton, style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateImage() {
        if let image = selectedSecondImage {
            secondImageView.image = image
            secondImageDeleteButton.isHidden = false
        }else if let image = selectedThirdImage {
            thirdImageView.image = image
            thirdImageDeleteButton.isHidden = false
        }
    }
    
    func saveImages() {
        if let image = selectedSecondImage {
            saveToParse(image: image)
        }
        
        if let image = selectedThirdImage {
            saveToParse(image: image)
        }
    }
    
    func saveToParse(image: UIImage) {
        do {
            let imageData: NSData = image.jpegData(compressionQuality: 1.0)! as NSData
            let imageFile: PFFileObject = PFFileObject(name:"image.jpg", data:imageData as Data)!
            try imageFile.save()

            let photoObject = PFObject(className: "Photos")
            photoObject.setObject(PFUser.current()?.objectId ?? "", forKey: "userid")
            photoObject.setObject(imageFile, forKey: "photo")
            photoObject.saveInBackground { (success, error) -> Void in
                self.startAnimating(self.view, startAnimate: false)
                if error != nil {
                    self.displayError(message: error?.localizedDescription ?? "")
                }else {
                    
                }
            }
        }catch {
            self.startAnimating(self.view, startAnimate: false)
        }
    }
    @IBAction func secondImageDeleteTapped(_ sender: Any) {
        secondImageView.image = UIImage(named: "add-image-icon")
        secondImageDeleteButton.isHidden = true
        selectedSecondImage = nil
        if let imageObjects = self.additionalImages {
            let query = PFQuery(className: "Photos")
            query.whereKey("objectId", equalTo: imageObjects[0].objectId ?? "")
            query.findObjectsInBackground { (response, error) in
                guard let imageObject = response?.first else {
                    return
                }
                imageObject.deleteInBackground()
            }
        }
    }
    
    @IBAction func thirdImageDeleteTapped(_ sender: Any) {
        thirdImageView.image = UIImage(named: "add-image-icon")
        thirdImageDeleteButton.isHidden = true
        selectedThirdImage = nil
        if let imageObjects = self.additionalImages {
            let query = PFQuery(className: "Photos")
            query.whereKey("objectId", equalTo: imageObjects[1].objectId ?? "")
            query.findObjectsInBackground { (response, error) in
                guard let imageObject = response?.first else {
                    return
                }
                imageObject.deleteInBackground()
            }
        }
    }
}

extension EditProfileViewController: ValidationDelegate {
    func validationSuccessful() {
        saveImages()
        
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


extension EditProfileViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 240
    }
}

extension EditProfileViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        guard let selectedImageView = self.selectedImageView else { return }
        if let image = image {
            if selectedImageView == secondImageView {
                self.selectedSecondImage =  image
            }else if selectedImageView == thirdImageView {
                self.selectedThirdImage = image
            }
            self.updateImage()
        }
    }
}
