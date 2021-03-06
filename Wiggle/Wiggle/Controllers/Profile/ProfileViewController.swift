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
    
    
    var slides:[SwipablePremiumView] = []
    var imagePicker: ImagePicker!
    var selectedImage: UIImage?
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4067151614085861/4960834755")
        let request = GADRequest()
//        interstitial.load(request)
//        checkForAdd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureBannerView()
    }

    
    func configureBannerView() {
        bannerView.adUnitID = "ca-app-pub-4067151614085861/4960834755"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .leading,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .leading,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .trailing,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .trailing,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func checkForAdd(){
        let shouldShow = Bool.random()
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            if self.interstitial.isReady && shouldShow && !(PFUser.current()?.getGold() ?? true){
                self.interstitial.present(fromRootViewController: self)
            }
        }
    }
    func configureViews() {
        guard PFUser.current() != nil else {
            return
        }
        settingsButton.cornerRadius(settingsButton.frame.height / 2)
        changePhotoButton.cornerRadius(changePhotoButton.frame.height / 2)
        editProfileButton.cornerRadius(editProfileButton.frame.height / 2)
        profilePhoto.cornerRadius(profilePhoto.frame.height / 2)
        imageBackgroundView.cornerRadius(imageBackgroundView.frame.height / 2)
        imageBackgroundView.clipsToBounds = false
        navigationController?.setNavigationBarHidden(true, animated: true)
        settingsLabel.text = Localize.Profile.Settings
        changePhotoLabel.text = Localize.Profile.ChangePhoto
        editProfileLabel.text = Localize.Profile.EditProfile
        updateViews()
    }
    
    func updateViews() {
        guard let user = PFUser.current() else {
            return
        }
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
        self.storeButton.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
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
