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
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        bottomScrollView.delegate = self
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
    
    func createSlides() -> [SwipablePremiumView] {
        
        bottomScrollView.subviews.forEach { $0.removeFromSuperview() }

        let slide1:SwipablePremiumView = SwipablePremiumView.instanceFromNib()
        slide1.prepare(title: "Kartlari Tekrar Gor", subtitle: "Kaydirdigin kartlari tekrar gorme firsati simdi Wiggle Gold'da")
        
        
        let slide2:SwipablePremiumView = SwipablePremiumView.instanceFromNib()
        slide2.prepare(title: "A real-life bear", subtitle: "Did you know that Winnie the chubby little cubby was based on a real, young bear in London")
        
        let slide3:SwipablePremiumView = SwipablePremiumView.instanceFromNib()
        slide3.prepare(title: "Kartlari Tekrar Gor", subtitle: "Kaydirdigin kartlari tekrar gorme firsati simdi Wiggle Gold'da")
        
        let slide4:SwipablePremiumView = SwipablePremiumView.instanceFromNib()
        slide4.prepare(title: "A real-life bear", subtitle: "Did you know that Winnie the chubby little cubby was based on a real, young bear in London")
        
        
        return [slide1, slide2, slide3, slide4]
    }
    
    func setupSlideScrollView(slides : [SwipablePremiumView]) {
        bottomScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: bottomScrollView.frame.height)
        bottomScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: bottomScrollView.frame.width * CGFloat(i), y: 0, width: self.view.frame.width, height: bottomScrollView.frame.height)
            bottomScrollView.addSubview(slides[i])
        }
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

extension ProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
            pageControl.currentPage = Int(pageIndex)
        }
}

extension ProfileViewController: UpdateInfoDelegate {
    func infosUpdated() {
        self.updateViews()
    }
}
