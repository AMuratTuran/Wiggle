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
    
    var registerRequest: RegisterRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    func prepareViews() {
        self.view.setGradientBackground()
        continueButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        bioTextView.layer.borderColor = UIColor.systemGray.cgColor
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.cornerRadius = 12.0
        bioTextView.delegate = self
        skipButton.setTitle(Localize.Common.SkipButton, for: .normal)
        topLabel.text = Localize.Bio.Title
    }
    
    @IBAction func continueAction(_ sender: Any) {
        guard let request = registerRequest else { return }
        request.bio = bioTextView.text
        moveToPickImageViewController(request: request)
    }
    
    @IBAction func skipAction(_ sender: UIButton) {
        guard let request = registerRequest else { return }
        moveToPickImageViewController(request: request)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension GetBioViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 240
    }
}

