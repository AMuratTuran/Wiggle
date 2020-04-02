//
//  WhoLikedViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 26.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import PopupDialog
import GoogleMobileAds

class WhoLikedViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likedButton: UIButton!
    @IBOutlet weak var matchedButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var buttonShadowView: UIView!
    @IBOutlet weak var buttonContainerView: UIView!
    
    
    var matchedUserData: [PFUser]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var likedYouData: [PFObject]?
    
    var usersLikedYouData: [PFUser]? {
        didSet {
            self.startAnimating(self.view, startAnimate: false)
            collectionView.reloadData()
        }
    }
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        getMatchData()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4067151614085861/4960834755")
        let request = GADRequest()
        interstitial.load(request)
        checkForAdd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureBannerView()
    }
    
    func configureBannerView() {
        bannerView.adUnitID = "ca-app-pub-4067151614085861/4960834755"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .leading,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .leading,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .trailing,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .trailing,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func checkForAdd(){
        let shouldShow = Bool.random()
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            if self.interstitial.isReady && shouldShow && !(PFUser.current()?.getGold() ?? true){
                self.interstitial.present(fromRootViewController: self)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        buttonShadowView.layer.applyShadow(color: UIColor(hexString: "A2834D"), alpha: 0.48, x: 0, y: 5, blur: 20)
    }
    
    func prepareViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.setGradientBackground()
        buttonContainerView.setWhiteGradient()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        collectionView.register(UINib(nibName: HeartbeatMatchCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: HeartbeatMatchCell.reuseIdentifier)
        collectionView.register(UINib(nibName: EmptyCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier)
        buttonsStackView.cornerRadius(25.0)
        buttonsStackView.clipsToBounds = true
        matchedButton.isSelected = true
        let image = UIImage(named: "chat-bubble")?.withRenderingMode(.alwaysTemplate)
        messagesButton.setImage(image, for: .normal)
    }
    
    
    func getMatchData() {
        if matchedUserData == nil {
            startAnimating(self.view, startAnimate: true)
            NetworkManager.getMatchedUsers(success: { (response) in
                self.startAnimating(self.view, startAnimate: false)
                self.matchedUserData = response
            }) { (error) in
                self.startAnimating(self.view, startAnimate: false)
                self.displayError(message: error)
            }
        }else {
            collectionView.reloadData()
        }
    }
    
    func getWhoLiked() {
        if let user = PFUser.current(), user.getGold() {
            if likedYouData == nil {
                startAnimating(self.view, startAnimate: true)
                NetworkManager.getWhoLikedYou(success: { (response) in
                    self.likedYouData = response
                    if !response.isEmpty {
                        self.getUserInfo()
                    }else {
                        self.startAnimating(self.view, startAnimate: false)
                    }
                }) { (error) in
                    self.startAnimating(self.view, startAnimate: false)
                    self.displayError(message: error)
                }
            }else {
                collectionView.reloadData()
            }
        }else {
            let goToStoreButton = DefaultButton(title: "WStore") {
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let destionationViewController = storyboard.instantiateViewController(withIdentifier: "SuperLikeInAppPurchaseViewController") as! SuperLikeInAppPurchaseViewController
                self.navigationController?.present(destionationViewController, animated: true, completion: {
                    self.switchToMatchScreen()
                })
            }
            let goToMatchScreen = DefaultButton(title: Localize.Common.Back) {
                self.switchToMatchScreen()
            }
            self.alertMessage(message: Localize.WhoLiked.Premium, buttons: [goToStoreButton, goToMatchScreen], isErrorMessage: true, isGestureDismissal: false)
        }
    }
    
    func getUserInfo() {
        guard let data = likedYouData else { return }
        var collectionViewData: [PFUser] = []
        data.forEach { like in
            let id = like["sender"] as! String
            NetworkManager.queryUsersById(id, success: { (user) in
                collectionViewData.append(user)
                if collectionViewData.count == data.count {
                    self.startAnimating(self.view, startAnimate: false)
                    self.usersLikedYouData = collectionViewData
                }
            }) { (error) in
                self.startAnimating(self.view, startAnimate: false)
            }
        }
    }
    
    fileprivate func switchToMatchScreen() {
        self.matchedButton.isSelected = true
        self.likedButton.isSelected = false
        self.matchedButton.setGradientBackground(colorOne: UIColor(hexString: "BC9A5F"), colorTwo: UIColor(hexString: "A2834D"))
        self.likedButton.backgroundColor = .clear
        self.getMatchData()
    }
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likedButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        matchedButton.isSelected = false
        likedButton.backgroundColor = UIColor(hexString: "D9B372")
        matchedButton.backgroundColor = UIColor.clear
        collectionView.reloadData()
        getWhoLiked()
    }
    
    @IBAction func matchedButtonTapped(_ sender: UIButton) {
        switchToMatchScreen()
        collectionView.reloadData()
    }
}

extension WhoLikedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if matchedButton.isSelected {
            guard let data = matchedUserData else { return 0 }
            if data.isEmpty {
                return 1
            }else {
                return data.count
            }
        }else {
            guard let data = usersLikedYouData else { return 0 }
            if data.isEmpty {
                return 1
            }else {
                return data.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeartbeatMatchCell.reuseIdentifier, for: indexPath) as! HeartbeatMatchCell
        let profileImageHeroId = "profileImage\(indexPath.row)"
        let nameHeroId = "name\(indexPath.row)"
        let subLabelId = "subLabel\(indexPath.row)"
        let contentViewId = "contentView\(indexPath.row)"
        cell.imageView.hero.id = profileImageHeroId
        cell.nameAndAgeLabel.hero.id = nameHeroId
        cell.locationLabel.hero.id = subLabelId
        if matchedButton.isSelected {
            guard let data = matchedUserData else { return UICollectionViewCell() }
            if data.isEmpty {
                let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
                emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
                return emptyCell
            }else {
                cell.prepare(with: data[indexPath.row])
            }
        }else {
            guard let data = usersLikedYouData else { return UICollectionViewCell() }
            if data.isEmpty {
                let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
                emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
                return emptyCell
            }else {
                cell.prepare(with: data[indexPath.row])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if matchedButton.isSelected {
            guard let data = matchedUserData else { return  .zero}
            if data.isEmpty {
                return collectionView.frame.size
            }else {
                let windowWidth = collectionView.frame.width - 40
                let cellWidth = windowWidth / 2
                return CGSize(width: cellWidth, height: cellWidth + 100)
            }
        }else {
            guard let data = usersLikedYouData else { return  .zero}
            if data.isEmpty {
                return collectionView.frame.size
            }else {
                let windowWidth = collectionView.frame.width - 40
                let cellWidth = windowWidth / 2
                return CGSize(width: cellWidth, height: cellWidth + 100)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var userData: PFUser!
        if matchedButton.isSelected {
            guard let data = matchedUserData, !data.isEmpty else { return }
            userData = data[indexPath.row]
        }else {
            guard let data = usersLikedYouData, !data.isEmpty else { return }
            userData = data[indexPath.row]
        }
        moveToProfileDetailFromWhoLiked(data: userData, index: indexPath.row)
    } 
}


extension WhoLikedViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1.0) {
            bannerView.alpha = 1
        }
    }
}
