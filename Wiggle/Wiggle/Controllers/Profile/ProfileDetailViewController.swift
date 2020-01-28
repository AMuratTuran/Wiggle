//
//  ProfileDetailViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var detailView: UIView!
    
    var userData: PFUser?
    var indexOfParentCell: Int?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.animate(withDuration: 0, delay: 0.1, animations: {
            self.backButton.alpha = 1
        }) { (isCompleted) in
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.alpha = 0
        profileImageView.hero.id = "profileImage\(indexOfParentCell ?? 0)"
        nameLabel.hero.id = "name\(indexOfParentCell ?? 0)"
        bioLabel.hero.id = "subLabel\(indexOfParentCell ?? 0)"
        self.view.hero.id = "contentView\(indexOfParentCell ?? 0)"
        backButton.cornerRadius(backButton.frame.height / 2)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        prepareViews()
    }
    
    func prepareViews() {
        guard let user = userData else { return }
        self.backButton.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
        let imageUrl = user.getPhotoUrl()
        profileImageView.kf.setImage(with: URL(string: imageUrl))
        nameLabel.text = "\(user.getFirstName()) \(user.getLastName()), \(user.getAge())"
        bioLabel.text = user.getBio()
    }

    
    @IBAction func backAction(sender: UIButton) {
        moveToHomeViewControllerFromProfileDetail()
    }

}
