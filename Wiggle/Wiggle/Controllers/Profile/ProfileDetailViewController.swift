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
import PromiseKit
import Kingfisher
import ImageSlideshow

class ProfileDetailViewController: UIViewController {
    
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
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    
    var userData: User?
    var indexOfParentCell: IndexPath?
    var isHomePage: Bool = true
    var isMatchesPages: Bool = false
    var likedYouPage: Bool = false
    var superLikeCount : Int = 0
    var delegate: userActionsDelegate?
    var discoverDelegate: DiscoverCellDelegate?
    let (promise, seal) = Promise<()>.pending()
    var slideShowUrls: [String]?
    
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
        prepareSlideShow()
        getImages()
    }
    
    func prepareHeroValues() {
        imageSlideShowView.hero.id = "profileImage\(indexOfParentCell?.row ?? 0)"
        nameLabel.hero.id = "name\(indexOfParentCell?.row ?? 0)"
        distanceLabel.hero.id = "subLabel\(indexOfParentCell?.row ?? 0)"
    }
    
    func prepareViews() {
        self.backButton.addShadow(UIColor(named: "shadowColor")!, shadowRadiues: 2.0, shadowOpacity: 0.4)
        self.view.backgroundColor = UIColor(hexString: "223C53")
        aboutMeLabel.text = Localize.Profile.Bio
        
        buttonsStackView.isHidden = isMatchesPages
        
        backButton.alpha = 0
        backButton.cornerRadius(backButton.frame.height / 2)
        backButton.setWhiteGradient()
        
        superlikeButton.cornerRadius(dislikeButton.frame.height / 2)
        superlikeButton.layer.applyShadow(color: UIColor(hexString: "BC9A5F"), alpha: 0.48, x: 0, y: 5, blur: 20)
        
        likeButton.cornerRadius(likeButton.frame.height / 2)
        likeButton.layer.applyShadow(color: UIColor.systemPink, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        dislikeButton.cornerRadius(dislikeButton.frame.height / 2)
        dislikeButton.setWhiteGradient()
        
        superLikeCount = PFUser.current()?.getSuperLike() ?? 0
        
        moreActionsButton.setWhiteGradient()
        moreActionsButton.setTitle(Localize.Profile.MoreActions, for: .normal)
        
        if let user = userData {
            aboutMeStackView.isHidden = user.bio.isEmpty
            bioLabel.text = user.bio
            nameLabel.text = "\(user.firstName) \(user.lastName), \(user.age ?? 0)"
            distanceLabel.text = "\(String(format: "%.1f", getDistance())) km"
        }
    }
    
    func prepareSlideShow() {
        imageSlideShowView.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        imageSlideShowView.contentScaleMode = .scaleAspectFit
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        imageSlideShowView.pageIndicator = pageControl
        
        imageSlideShowView.activityIndicator = DefaultActivityIndicator()
        imageSlideShowView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageSlideShowView.addGestureRecognizer(recognizer)
    }
    
    @objc func didTap() {
        let fullScreenController = imageSlideShowView.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func getImages() {
        if let user = userData {
            NetworkManager.getImages(by: user.objectId, success: { (response) in
                self.slideShowUrls = response
                self.setSlideShowImages()
            }) { (error) in
                
            }
        }
    }
    
    func setSlideShowImages() {
        var inputSources: [InputSource] = []
        if let user = userData {
            let imageUrl = user.image
            if let imageUrl = imageUrl, !imageUrl.isEmpty {
                if let source = KingfisherSource(urlString: imageUrl) {
                    inputSources.append(source)
                }
            }
        }
        
        guard let imageUrls = self.slideShowUrls else {
            imageSlideShowView.setImageInputs(inputSources)
            return
        }
        
        imageUrls.forEach { url in
            if let source = KingfisherSource(urlString: url) {
                inputSources.append(source)
            }
        }
        imageSlideShowView.setImageInputs(inputSources)
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        self.dismiss(animated: true) {
            if let indexPath = self.indexOfParentCell {
                self.discoverDelegate?.likeTapped(at: indexPath)
            }
        }
    }
    @IBAction func starButtonAction(_ sender: Any) {
        self.dismiss(animated: true) {
            if let indexPath = self.indexOfParentCell {
                self.discoverDelegate?.superLikeTapped(at: indexPath)
            }
        }
    }
    @IBAction func dislikeButtonAction(_ sender: Any) {
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
        
        let unmatchAction = UIAlertAction(title: Localize.Chat.Unmatch, style: .default) { (action) in
            self.unmatchAction()
        }
        let reportAction = UIAlertAction(title: Localize.Chat.Report, style: .default) { (action) in
            self.reportAction()
        }
        let blockAction = UIAlertAction(title: Localize.Report.Block, style: .default) { (action) in
            self.blockAction()
        }
        let cancelAction = UIAlertAction(title: Localize.Common.CancelButton, style: .cancel) { (action) in
            
        }
        if isMatchesPages {
            alertController.addAction(unmatchAction)
        }
        alertController.addAction(reportAction)
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func unmatchAction() {
        if let user = userData {
            let cancelButton = DefaultButton(title: Localize.Common.Close) {
            }
            
            NetworkManager.unMatch(myId: AppConstants.objectId, contactedUserId: user.objectId, success: {
                self.dismiss(animated: true) {
                    self.seal.fulfill(())
                }
            }) { (error) in
                self.seal.reject(error!)
                self.alertMessage(message: error?.localizedDescription ?? "", buttons: [cancelButton], isErrorMessage: false)
            }
        }
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
                if self.isHomePage {
                    self.dismiss(animated: true) {
                        if let indexPath = self.indexOfParentCell {
                            self.discoverDelegate?.dislikeTapped(at: indexPath)
                        }
                    }
                }else {
                    self.delegate?.dislikeAction(receiverObjectId: receiverObjectId, direction: SwipeResultDirection(rawValue: "left") ?? .down)
                    self.moveToHomeViewControllerFromProfileDetail()
                }
            }
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
    
    func hideDislikeButton() {
        self.dislikeButton.isHidden = true
    }
    
    func hideButtons() {
        self.buttonsStackView.isHidden = true
    }
}

extension ProfileDetailViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        
    }
}
