//
//  ProfileViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import GoogleMobileAds
import PopupDialog

class ProfileViewController: UIViewController {
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var changePhotoLabel: UILabel!
    @IBOutlet weak var editProfileLabel: UILabel!
    @IBOutlet weak var boostView: UIView!
    @IBOutlet weak var useBoostButton: UIButton!
    @IBOutlet weak var remainingBoostDescLabel: UILabel!
    @IBOutlet weak var remainingBoostLabel: UILabel!
    
    
    var slides:[SwipablePremiumView] = []
    var imagePicker: ImagePicker!
    var selectedImage: UIImage?
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var boostCount: Int = 0 {
        didSet {
            self.remainingBoostLabel.text = "\(boostCount)"
            if boostCount != 0 {
                self.useBoostButton.setTitle(Localize.Profile.UseBoostButton, for: .normal)
            }else {
                self.useBoostButton.setTitle(Localize.Profile.BuyBoostButton, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getBoostCount()
    }
    
    func getBoostCount() {
        PFUser.current()?.fetchInBackground(block: { (object, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let user = object as? PFUser else {
                self.boostCount = 0
                return
            }
            
            if let count = user.object(forKey: "boost") as? Int {
                self.boostCount = count
            }else {
                self.boostCount = 0
            }
        })
    }
    func configureViews() {
        
        guard PFUser.current() != nil else {
            return
        }

        transparentTabBar()
        self.view.setGradientBackground()
        
        settingsButton.cornerRadius(settingsButton.frame.height / 2)
        settingsButton.setWhiteGradient()
        
        changePhotoButton.cornerRadius(changePhotoButton.frame.height / 2)
        changePhotoButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        editProfileButton.cornerRadius(editProfileButton.frame.height / 2)
        editProfileButton.setWhiteGradient()
        
        boostView.cornerRadius(boostView.frame.height / 2)
        boostView.addBorder(UIColor(hexString: "D9B372"), width: 1)

        useBoostButton.cornerRadius(useBoostButton.frame.height / 2)
        
        profilePhoto.cornerRadius(profilePhoto.frame.height / 2)
        imageBackgroundView.cornerRadius(imageBackgroundView.frame.height / 2)
        imageBackgroundView.clipsToBounds = false
        
        profilePhoto.addBorder(UIColor(hexString: "D9B372"), width: 3)
        
        storeButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        settingsLabel.text = Localize.Profile.Settings
        changePhotoLabel.text = Localize.Profile.ChangePhoto
        editProfileLabel.text = Localize.Profile.EditProfile
        
        remainingBoostDescLabel.text = Localize.Profile.RemainingBoost
        
        updateViews()
    }
    
    func updateViews() {
        guard let user = PFUser.current() else {
            return
        }
        let imageUrl = user.getPhotoUrl()
        profilePhoto.kf.indicatorType = .activity
        profilePhoto.kf.setImage(with: URL(string: imageUrl ?? ""))
        let age = "\(user.getAge())"
        let name = "\(user.getFirstName()) \(user.getLastName())"
        nameAndAgeLabel.text = "\(name), \(age)"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func updateImage() {
        guard let user = PFUser.current() else {
            return
        }
        let imageUrl = user.getPhotoUrl()
        profilePhoto.kf.indicatorType = .activity
        profilePhoto.kf.setImage(with: URL(string: imageUrl ?? ""))
    }
    
    @IBAction func routeSettingsAction(_ sender: UIButton) {
        moveToSettingsViewController()
    }
    
    @IBAction func changePhotoTapped(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func editProfileAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        destinationVC.delegate = self
        let nav = UINavigationController(rootViewController: destinationVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func storeButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
        self.navigationController?.present(destionationViewController, animated: true, completion: {})
    }
    
    @IBAction func useBoost(_ sender: Any) {
        if boostCount > 0 {
            let boost = PFObject(className: "Boost")
            boost.setValue(User.current?.objectId ?? "", forKey: "userId")
            boost.saveInBackground { (result, error) in
                if let error = error {
                    self.alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
                }
                
                if result {
                    self.alertMessage(message: Localize.Profile.BoostUsedText, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
                    self.getBoostCount()
                }
            }
        }else {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "SuperLikeInAppPurchaseViewController") as! SuperLikeInAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
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
                self.startAnimating(self.view, startAnimate: false)
            }
        }else {
            self.startAnimating(self.view, startAnimate: false)
        }
    }
}


extension ProfileViewController: UpdateInfoDelegate {
    func infosUpdated() {
        self.updateViews()
    }
}


extension ProfileViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1.0) {
            bannerView.alpha = 1
        }
    }
}
