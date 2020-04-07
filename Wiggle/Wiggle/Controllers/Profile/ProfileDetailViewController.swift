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
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var aboutMeStackView: UIStackView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var moreActionsButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var superlikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var userData: User?
    var indexOfParentCell: IndexPath?
    var isHomePage: Bool = true
    var superLikeCount : Int = 0
    var delegate: userActionsDelegate?
    var discoverDelegate: DiscoverCellDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.animate(withDuration: 0, delay: 0.1, animations: {
            self.backButton.alpha = 1
        }) { (isCompleted) in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        prepareHeroValues()
    }
    
    func prepareHeroValues() {
        profileImageView.hero.id = "profileImage\(indexOfParentCell?.row ?? 0)"
        nameLabel.hero.id = "name\(indexOfParentCell?.row ?? 0)"
        distanceLabel.hero.id = "subLabel\(indexOfParentCell?.row ?? 0)"
    }
    
    func prepareViews() {
        self.backButton.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
        setDefaultGradientBackground()
        aboutMeLabel.text = Localize.Profile.Bio
        
        backButton.alpha = 0
        backButton.cornerRadius(backButton.frame.height / 2)
        backButton.setWhiteGradient()
        
        superlikeButton.cornerRadius(dislikeButton.frame.height / 2)
        superlikeButton.layer.applyShadow(color: UIColor(hexString: "BC9A5F"), alpha: 0.48, x: 0, y: 5, blur: 20)
        
        likeButton.cornerRadius(likeButton.frame.height / 2)
        likeButton.layer.applyShadow(color: UIColor.systemPink, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        dislikeButton.cornerRadius(dislikeButton.frame.height / 2)
        dislikeButton.setWhiteGradient()
        
        //reportButton.setTitle(Localize.Report.ReportTitle, for: .normal)
        //blockButton.setTitle(Localize.Report.Block, for: .normal)
        
        superLikeCount = PFUser.current()?.getSuperLike() ?? 0
        
        moreActionsButton.setWhiteGradient()
        
        if let user = userData {
            let imageUrl = user.image
            if !(imageUrl?.isEmpty ?? false) {
                profileImageView.kf.setImage(with: URL(string: imageUrl ?? ""))
            }else {
                profileImageView.image = UIImage(named: "profilePicture")
            }
            aboutMeStackView.isHidden = user.bio.isEmpty
            bioLabel.text = user.bio
            nameLabel.text = "\(user.firstName) \(user.lastName), \(user.age ?? 0)"
            distanceLabel.text = "\(String(format: "%.1f", getDistance())) km"
        }
    }
    
        @IBAction func likeButtonAction(_ sender: Any) {
//            if let receiverObjectId = wiggleCardModel?.objectId{
//                delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "right") ?? .down)
//            }else if let receiverObjectId = userData?.objectId{
//                showToastMessage(title: Localize.Profile.LikeToastTitle, body: Localize.Profile.LikeToastBody)
//                delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "right") ?? .down)
//            }
//            moveToHomeViewControllerFromProfileDetail()
            self.dismiss(animated: true) {
                if let indexPath = self.indexOfParentCell {
                    self.discoverDelegate?.likeTapped(at: indexPath)
                }
            }
        }
        @IBAction func starButtonAction(_ sender: Any) {
//            if let receiverObjectId = wiggleCardModel?.objectId{
//                delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "up") ?? .down)
//            }else if let receiverObjectId = userData?.objectId{
//                delegate?.likeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "up") ?? .down)
//            }
//            moveToHomeViewControllerFromProfileDetail()
            self.dismiss(animated: true) {
                if let indexPath = self.indexOfParentCell {
                    self.discoverDelegate?.superLikeTapped(at: indexPath)
                }
            }
        }
        @IBAction func dislikeButtonAction(_ sender: Any) {
//            if let receiverObjectId = wiggleCardModel?.objectId{
//                delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
//            }else if let receiverObjectId = userData?.objectId{
//                delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
//            }
//            moveToHomeViewControllerFromProfileDetail()
            self.dismiss(animated: true) {
                if let indexPath = self.indexOfParentCell {
                    self.discoverDelegate?.dislikeTapped(at: indexPath)
                }
            }
        }
    
    func getDistance() -> Double {
        if let user = User.current, let data = self.userData {
            let myLocation = CLLocation(latitude: user.latitude ?? 0, longitude: user.longitude ?? 0)
            let userLocation = CLLocation(latitude: data.latitude ?? 0, longitude: data.longitude ?? 0 )
            let distanceInMeters = myLocation.distance(from: userLocation)
            let distanceInKm = distanceInMeters / 1000
            return Double(distanceInKm)
        }else {
            return 0
        }
    }
    
    func moreActions() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: Localize.Chat.Report, style: .default) { (action) in
            self.reportAction()
        }
        let blockAction = UIAlertAction(title: Localize.Report.Block, style: .default) { (action) in
            self.blockAction()
        }
        let cancelAction = UIAlertAction(title: Localize.Common.CancelButton, style: .cancel) { (action) in
            
        }
        
        alertController.addAction(reportAction)
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backAction(sender: UIButton) {
        moveToHomeViewControllerFromProfileDetail()
    }
    
    func reportAction() {
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

    func blockAction() {
        let yesButton = DefaultButton(title: Localize.Common.Yes) {
            self.reportButtonAction(isBlockAction: true)
        }
        
        let cancelButton = DefaultButton(title: Localize.Common.Close) {
            
        }
        
        cancelButton.titleColor = .systemRed
        
        self.alertMessage(title: Localize.Report.Block, message: Localize.Report.BlockDesc, buttons: [yesButton, cancelButton], buttonAlignment: .horizontal, isErrorMessage: false)
    }
    
    @IBAction func moreActionsTapped(_ sender: Any) {
        moreActions()
    }
    
    func reportButtonAction(isBlockAction: Bool = false) {
        
        self.startAnimating(self.view, startAnimate: true)
        let cancelButton = DefaultButton(title: Localize.Common.Close) {
            if let receiverObjectId = self.userData?.objectId {
                self.delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
            }
            self.moveToHomeViewControllerFromProfileDetail()
        }
        
        if isHomePage {
            delay(1.0) {
                self.startAnimating(self.view, startAnimate: false)
                let succesMessage = isBlockAction ? Localize.Report.BlockSuccessMessage : Localize.Report.SuccessMessage
                self.alertMessage(message: succesMessage, buttons: [cancelButton], isErrorMessage: false)
            }
        }else {
            NetworkManager.unMatch(myId: "", contactedUserId: userData?.objectId ?? "", success: {
                self.startAnimating(self.view, startAnimate: false)
                let succesMessage = isBlockAction ? Localize.Report.BlockSuccessMessage : Localize.Report.SuccessMessage
                self.alertMessage(message: succesMessage, buttons: [cancelButton], isErrorMessage: false)
            }) { (error) in
                self.startAnimating(self.view, startAnimate: false)
                let succesMessage = isBlockAction ? Localize.Report.BlockSuccessMessage : Localize.Report.SuccessMessage
                self.alertMessage(message: succesMessage, buttons: [cancelButton], isErrorMessage: false)
            }
        }
    }
}

