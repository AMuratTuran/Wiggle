//
//  ProfileDetailViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import Koloda
import PopupDialog

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var detailView: UIView!
    
    var wiggleCardModel: WiggleCardModel?
    var userData: PFUser?
    var indexOfParentCell: Int?
    
    var superLikeCount : Int = 0
    
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
        superLikeCount = PFUser.current()?.getSuperLike() ?? 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        prepareViews()
    }
    
    func prepareViews() {
        self.backButton.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
        if let user = wiggleCardModel{
            profileImageView.heroID = "fromHomeProfilePicture"
            nameLabel.heroID = "fromHomeName"
            bioLabel.heroID = "fromHomeBio"
            if let photoUrl = user.profilePicture{
                if !photoUrl.isEmpty{
                    profileImageView.kf.setImage(with: URL(string: photoUrl))
                }else{
                    profileImageView.image = UIImage(named: "profilePicture")
                }
            }else{
                profileImageView.image = UIImage(named: "profilePicture")
            }
            nameLabel.text = user.nameSurname
            bioLabel.text = user.bio
        }else if let user = userData{
            let imageUrl = user.getPhotoUrl()
            if !imageUrl.isEmpty{
                profileImageView.kf.setImage(with: URL(string: imageUrl))
            }else{
                profileImageView.image = UIImage(named: "profilePicture")
            }
            nameLabel.text = "\(user.getFirstName()) \(user.getLastName()), \(user.getAge())"
            bioLabel.text = user.getBio()
        }
    }

    @IBAction func likeButtonAction(_ sender: Any) {
        let cancelButton = DefaultButton(title: Localize.Common.CancelButton) {}
        let goToStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        if let receiverObjectId = wiggleCardModel?.objectId{
            NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down, success: {
            }) { (err) in
                if err.contains("1007"){
                    self.alertMessage(message: "Likeların bitti almak için store'a git", buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
                }
            }
        }else if let receiverObjectId = userData?.objectId{
            NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down, success: {
            }) { (err) in
                if err.contains("1007"){
                    self.alertMessage(message: "Likeların bitti almak için store'a git", buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
                }
            }
        }
        moveToHomeViewControllerFromProfileDetail()
    }
    @IBAction func starButtonAction(_ sender: Any) {
        let cancelButton = DefaultButton(title: Localize.Common.CancelButton) {}
        let goToStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        if superLikeCount <= 0{
            self.alertMessage(message: "Super Likeların bitti almak için store'a git", buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
        }else{
            if let receiverObjectId = wiggleCardModel?.objectId{
                NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: SwipeResultDirection(rawValue: "up") ?? .down, success: {
                }) { (_) in}
            }else if let receiverObjectId = userData?.objectId{
                NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: SwipeResultDirection(rawValue: "up") ?? .down, success: {
                }) { (_) in}
            }
            moveToHomeViewControllerFromProfileDetail()
        }
    }
    @IBAction func dislikeButtonAction(_ sender: Any) {
        let cancelButton = DefaultButton(title: Localize.Common.CancelButton) {}
        let goToStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        if let receiverObjectId = wiggleCardModel?.objectId{
            NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: SwipeResultDirection(rawValue: "right") ?? .down, success: {
            }) { (err) in
                if err.contains("1007"){
                    self.alertMessage(message: "Likeların bitti almak için store'a git", buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
                }
            }
        }else if let receiverObjectId = userData?.objectId{
            NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: SwipeResultDirection(rawValue: "right") ?? .down, success: {
            }) { (err) in
                if err.contains("1007"){
                    self.alertMessage(message: "Likeların bitti almak için store'a git", buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
                }
            }
        }
        moveToHomeViewControllerFromProfileDetail()
    }
    
    @IBAction func backAction(sender: UIButton) {
        moveToHomeViewControllerFromProfileDetail()
    }

}
