//
//  GetBioViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 20.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class GetBioViewController: UIViewController {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    func prepareViews() {
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        bioTextView.layer.borderColor = UIColor.systemGray.cgColor
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.cornerRadius = 12.0
        skipButton.setTitle(Localize.Common.SkipButton, for: .normal)
        topLabel.text = Localize.Bio.Title
    }
    
    @IBAction func continueAction(_ sender: Any) {
        startAnimating(self.view, startAnimate: true)
        let bio = bioTextView.text
        PFUser.current()?.setValue(bio, forKey: "bio")
        PFUser.current()?.saveInBackground(block: { (result, error) in
            self.startAnimating(self.view, startAnimate: false)
            if error != nil {
                self.displayError(message: error?.localizedDescription ?? "")
            }else {
                self.moveToPickImageViewController(navigationController: self.navigationController ?? UINavigationController())
            }
        })
    }
    @IBAction func skipAction(_ sender: UIButton) {
        moveToPickImageViewController(navigationController: self.navigationController ?? UINavigationController())
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

