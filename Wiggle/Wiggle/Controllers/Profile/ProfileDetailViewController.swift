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
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    
    var wiggleCardModel: WiggleCardModel?
    var userData: PFUser?
    var indexOfParentCell: Int?
    
    var superLikeCount : Int = 0
    
    var delegate: userActionsDelegate?
    
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
            reportButton.setTitle(Localize.Report.ReportTitle, for: .normal)
            blockButton.setTitle(Localize.Report.Block, for: .normal)
        }else if let user = userData{
            let imageUrl = user.getPhotoUrl()
            if !imageUrl.isEmpty{
                profileImageView.kf.setImage(with: URL(string: imageUrl))
            }else{
                profileImageView.image = UIImage(named: "profilePicture")
            }
            nameLabel.text = "\(user.getFirstName()) \(user.getLastName()), \(user.getAge())"
            bioLabel.text = user.getBio()
            reportButton.setTitle(Localize.Report.ReportTitle, for: .normal)
            blockButton.setTitle(Localize.Report.Block, for: .normal)
        }
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        if let receiverObjectId = wiggleCardModel?.objectId{
            delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "right") ?? .down)
        }else if let receiverObjectId = userData?.objectId{
            delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "right") ?? .down)
        }
        moveToHomeViewControllerFromProfileDetail()
    }
    @IBAction func starButtonAction(_ sender: Any) {
        if let receiverObjectId = wiggleCardModel?.objectId{
            delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "up") ?? .down)
        }else if let receiverObjectId = userData?.objectId{
            delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "up") ?? .down)
        }
        moveToHomeViewControllerFromProfileDetail()
    }
    @IBAction func dislikeButtonAction(_ sender: Any) {
        if let receiverObjectId = wiggleCardModel?.objectId{
            delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
        }else if let receiverObjectId = userData?.objectId{
            delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
        }
        moveToHomeViewControllerFromProfileDetail()
    }
    
    @IBAction func backAction(sender: UIButton) {
        moveToHomeViewControllerFromProfileDetail()
    }
    
    @IBAction func reportAction(_ sender: Any) {
        let messageButton = DefaultButton(title: Localize.Report.Message) {
            self.reportButtonAction()
        }
        let photoButton = DefaultButton(title: Localize.Report.Photo) {
            self.reportButtonAction()
        }
        let spamButton = DefaultButton(title: Localize.Report.Spam) {
            self.reportButtonAction()
        }
        
        let cancelButton = DefaultButton(title: Localize.Common.Close) {
            
        }
        cancelButton.titleColor = .systemRed
        
        self.alertMessage(title: Localize.Report.ReportTitle, message: Localize.Report.SelectReason, buttons: [messageButton, photoButton, spamButton, cancelButton], buttonAlignment: .vertical, isErrorMessage: false)
    }

    @IBAction func blockAction(_ sender: Any) {
        let yesButton = DefaultButton(title: Localize.Common.Yes) {
            self.reportButtonAction(isBlockAction: true)
        }
        
        let cancelButton = DefaultButton(title: Localize.Common.Close) {
            
        }
        
        cancelButton.titleColor = .systemRed
        
        self.alertMessage(title: Localize.Report.Block, message: Localize.Report.BlockDesc, buttons: [yesButton, cancelButton], buttonAlignment: .horizontal, isErrorMessage: false)
    }
        
    func reportButtonAction(isBlockAction: Bool = false) {
        self.startAnimating(self.view, startAnimate: true)
        let cancelButton = DefaultButton(title: Localize.Common.Close) {
            if let receiverObjectId = self.wiggleCardModel?.objectId{
                self.delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
            }else if let receiverObjectId = self.userData?.objectId{
                self.delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
            }
            self.moveToHomeViewControllerFromProfileDetail()
        }
        NetworkManager.unMatch(myId: "", contactedUserId: userData?.objectId ?? "", success: {
            self.startAnimating(self.view, startAnimate: false)
            let succesMessage = isBlockAction ? Localize.Report.BlockSuccessMessage : Localize.Report.SuccessMessage
            self.alertMessage(message: succesMessage, buttons: [cancelButton], isErrorMessage: false)
        }) { (error) in
            self.startAnimating(self.view, startAnimate: false)
            self.alertMessage(message: Localize.Report.SuccessMessage, buttons: [cancelButton], isErrorMessage: false)
        }
    }
}
