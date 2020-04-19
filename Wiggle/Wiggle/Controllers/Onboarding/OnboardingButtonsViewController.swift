//
//  OnboardingButtonsViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class OnboardingButtonsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var superlikeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        hightlightSuperlikeButton()
    }
    
    func prepareViews() {
        setDefaultGradientBackground()
        transparentNavigationBar()
        descriptionLabel.text = Localize.Onboarding.ButtonsDesc
        nextButton.title = Localize.Common.Done
        nextButton.isEnabled = false
    }
    
    func hightlightSuperlikeButton() {
        UIView.animate(withDuration: 0.4, animations: {
            self.profileImageView.alpha = 0.25
            self.superlikeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        }, completion: { _ in
            delay(1.5) {
                self.hightlightDislikeButton()
            }
        })
    }
    
    func hightlightDislikeButton() {
        UIView.animate(withDuration: 0.4, animations:  {
            self.profileImageView.alpha = 0.25
            self.superlikeButton.transform = .identity
            self.superlikeButton.alpha = 0.5
            self.dislikeButton.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        }, completion: { _ in
            UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
            self.nextButton.isEnabled = true
        })
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
