//
//  GenderViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 21.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class GenderViewController: UIViewController {

    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleView: UIView!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    var selectedGender: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    func prepareViews() {
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        self.startAnimating(self.view, startAnimate: true)
        PFUser.current()?.setValue(selectedGender, forKey: "gender")
        AppConstants.gender = selectedGender
        PFUser.current()?.saveInBackground(block: { (result, error) in
            self.startAnimating(self.view, startAnimate: false)
            if error != nil {
                self.displayError(message: error?.localizedDescription ?? "")
            }else {
                self.moveToGetBioViewController(navigationController: self.navigationController ?? UINavigationController())
            }
        })
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func maleTapped(_ sender: Any) {
        visibleBorders(view: maleView)
        clearBorders(view: femaleView)
        self.selectedGender = 1
    }
    
    @IBAction func femaleTapped(_ sender: Any) {
        visibleBorders(view: femaleView)
        clearBorders(view: maleView)
        self.selectedGender = 2
    }
    
    func visibleBorders(view: UIView) {
        view.addBorder(.systemBlue, width: 1)
        view.cornerRadius(12)
    }
    
    func clearBorders(view: UIView) {
        view.layer.borderWidth = 0
    }
}
