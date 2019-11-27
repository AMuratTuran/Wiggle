//
//  ProfileViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var routeToHomeButton: UIButton!
    @IBOutlet weak var imageBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
        configureViews()
        // Do any additional setup after loading the view.
    }
    
    func configureViews() {
        settingsButton.cornerRadius(settingsButton.frame.height / 2)
        changePhotoButton.cornerRadius(changePhotoButton.frame.height / 2)
        editProfileButton.cornerRadius(editProfileButton.frame.height / 2)
        profilePhoto.cornerRadius(profilePhoto.frame.height / 2)
        imageBackgroundView.cornerRadius(imageBackgroundView.frame.height / 2)
        imageBackgroundView.clipsToBounds = false
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

    @IBAction func routeHomeAction(_ sender: UIButton) {
        moveToHomeViewControllerFromProfile()
    }
    
    @IBAction func routeSettingsAction(_ sender: UIButton) {
        moveToSettingsViewController()
    }
}
