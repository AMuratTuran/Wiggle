//
//  PickImageViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 20.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class PickImageViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var pickImageButton: UIButton!
    
    @IBOutlet weak var tapAgainLabel: UILabel!
    @IBOutlet weak var pickImageButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickImageButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var skipButton: UIButton!
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        prepareViews()
    }
    
    func prepareViews() {
        skipButton.setTitle(Localize.Common.SkipButton, for: .normal)
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func pickImageAction(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    @IBAction func continueAction(_ sender: UIButton) {
        moveToBirthdayViewController(navigationController: self.navigationController ?? UINavigationController())
    }
    @IBAction func skipButton(_ sender: UIButton) {
        moveToBirthdayViewController(navigationController: self.navigationController ?? UINavigationController())
    }
    
    func roundButton() {
        pickImageButtonHeightConstraint.constant = 180.0
        pickImageButtonWidthConstraint.constant = 180.0
        pickImageButton.layer.borderWidth = 1.0
        if #available(iOS 13.0, *) {
            pickImageButton.layer.borderColor = UIColor.systemGray2.cgColor
        } else {
            pickImageButton.layer.borderColor = UIColor.gray.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pickImageButton.layer.cornerRadius = self.pickImageButton.frame.width / 2
            self.pickImageButton.clipsToBounds = true
            self.tapAgainLabel.isHidden = false
        }
    }
    
    func resetButtonFrame() {
        pickImageButtonHeightConstraint.constant = 120.0
        pickImageButtonWidthConstraint.constant = 150.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.pickImageButton.layer.cornerRadius = 0
            self.pickImageButton.clipsToBounds = true
            self.pickImageButton.setImage(UIImage(named: "person.crop.circle.fill.badge.plus"), for: .normal)
            self.tapAgainLabel.isHidden = true
        }
    }
}

extension PickImageViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        if let image = image {
            self.pickImageButton.setBackgroundImage(image, for: .normal)
            roundButton()
        }else {
            resetButtonFrame()
        }
    }
}
