//
//  EditProfileViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    func configureViews() {
        guard let user = PFUser.current() else {
            return
        }
        let imageUrl = user.getPhotoUrl()
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: URL(string: imageUrl))
        
        let nameTextFieldView = TextFieldView.load(title: "", placeholder: "")
        nameTextFieldView.text = user.getFirstName()
        nameStackView.addArrangedSubview(nameTextFieldView)
        let lastnameTextFieldView = TextFieldView.load(title: "", placeholder: "")
        lastnameTextFieldView.text = user.getLastName()
        nameStackView.addArrangedSubview(lastnameTextFieldView)
    }

}
