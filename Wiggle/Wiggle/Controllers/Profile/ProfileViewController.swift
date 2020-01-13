//
//  ProfileViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    
    
    var imagePicker: ImagePicker!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    func configureViews() {
        guard let user = PFUser.current() else {
            return
        }
        settingsButton.cornerRadius(settingsButton.frame.height / 2)
        changePhotoButton.cornerRadius(changePhotoButton.frame.height / 2)
        editProfileButton.cornerRadius(editProfileButton.frame.height / 2)
        profilePhoto.cornerRadius(profilePhoto.frame.height / 2)
        imageBackgroundView.cornerRadius(imageBackgroundView.frame.height / 2)
        imageBackgroundView.clipsToBounds = false
        navigationController?.setNavigationBarHidden(true, animated: true)
        let imageUrl = user.getPhotoUrl()
        profilePhoto.kf.indicatorType = .activity
        profilePhoto.kf.setImage(with: URL(string: imageUrl))
        let age = "\(user.getAge())"
        let name = "\(user.getFirstName()) \(user.getLastName())"
        nameAndAgeLabel.text = "\(name), \(age)"
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        prepareViews()
    }
    
    func prepareViews() {
        self.settingsButton.addShadow(UIColor(named: "shadowColor")!)
        self.changePhotoButton.addShadow(UIColor(named: "shadowColor")!)
        self.editProfileButton.addShadow(UIColor(named: "shadowColor")!)
        self.imageBackgroundView.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
    }
    
    func updateImage() {
        guard let user = PFUser.current() else {
            return
        }
        let imageUrl = user.getPhotoUrl()
        profilePhoto.kf.indicatorType = .activity
        profilePhoto.kf.setImage(with: URL(string: imageUrl))
    }
    
    @IBAction func routeSettingsAction(_ sender: UIButton) {
        moveToSettingsViewController()
    }
    @IBAction func changePhotoTapped(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
}

extension ProfileViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.startAnimating(self.view, startAnimate: true)
        if let image = image {
            self.selectedImage = image
            do {
                let imageData: NSData = image.jpegData(compressionQuality: 1.0)! as NSData
                let imageFile: PFFileObject = PFFileObject(name:"image.jpg", data:imageData as Data)!
                try imageFile.save()
                
                let user = PFUser.current()
                user?.setObject(imageFile, forKey: "photo")
                user?.saveInBackground { (success, error) -> Void in
                    self.startAnimating(self.view, startAnimate: false)
                    if error != nil {
                        self.displayError(message: error?.localizedDescription ?? "")
                    }else {
                        self.updateImage()
                    }
                }
            }catch {
                
            }
        }
    }
}
