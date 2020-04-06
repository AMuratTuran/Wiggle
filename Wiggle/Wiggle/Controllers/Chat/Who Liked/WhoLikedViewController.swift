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

class WhoLikedViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var switchButton: UISwitch!
    
    
    var matchedUserData: [User] = []
    var likedYouData: [PFObject]?
    var usersLikedYouData: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        getMatchData()
    }
    
    func prepareViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.setGradientBackground()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        collectionView.register(UINib(nibName: HeartbeatMatchCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: HeartbeatMatchCell.reuseIdentifier)
        collectionView.register(UINib(nibName: EmptyCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier)
        
        switchButton.isOn = true
        switchButton.onTintColor = UIColor(hexString: "BC9A5F")
        switchButton.tintColor = UIColor(hexString: "BC9A5F")
        switchButton.thumbTintColor = UIColor.white
        switchButton.backgroundColor = UIColor(hexString: "BC9A5F")
        switchButton.layer.cornerRadius = 16
        
        let image = UIImage(named: "chat-bubble")?.withRenderingMode(.alwaysTemplate)
        messagesButton.setImage(image, for: .normal)
    }
    
    
    func getMatchData() {
        startAnimating(self.view, startAnimate: true)
        NetworkManager.getMatchedUsers(success: { (response) in
            self.startAnimating(self.view, startAnimate: false)
            response.forEach { user in
                let userModel = User(parseUser: user)
                self.matchedUserData.append(userModel)
            }
            DispatchQueue.main.async {
                delay(0.3) {
                    self.collectionView.reloadData()
                }
            }
        }) { (error) in
            self.startAnimating(self.view, startAnimate: false)
            self.displayError(message: error)
        }
    }
    
    func getWhoLiked() {
        if let user = PFUser.current() {
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
        var collectionViewData: [User] = []
        data.forEach { like in
            let id = like["sender"] as! String
            NetworkManager.queryUsersById(id, success: { (user) in
                let userModel = User(parseUser: user)
                collectionViewData.append(userModel)
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
        
        self.getMatchData()
    }
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likedButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        
        collectionView.reloadData()
        getWhoLiked()
    }
    
    @IBAction func matchedButtonTapped(_ sender: UIButton) {
        switchToMatchScreen()
        collectionView.reloadData()
    }
    @IBAction func switchChanged(_ sender: UISwitch) {
        if switchButton.isOn {
            getWhoLiked()
        }else {
            getMatchData()
        }
    }
    
    func dislikeAndRemove(indexPath: IndexPath) {
        self.usersLikedYouData.remove(at: indexPath.row)
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
    }
    
    func superLikeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        usersLikedYouData[indexPath.row].isLiked = true
        _ = cell.playSuperLikeAnimation().done { _ in
            self.usersLikedYouData.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func likeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        usersLikedYouData[indexPath.row].isLiked = true
        _ = cell.playLikeAnimation().done { _ in
            self.usersLikedYouData.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
}

extension WhoLikedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !switchButton.isOn {
            if matchedUserData.isEmpty {
                return 1
            }else {
                return matchedUserData.count
            }
        }else {
            if usersLikedYouData.isEmpty {
                return 1
            }else {
                return usersLikedYouData.count
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
        if !switchButton.isOn {
            if matchedUserData.isEmpty {
                let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
                emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
                return emptyCell
            }else {
                cell.prepare(with: matchedUserData[indexPath.row])
            }
        }else {
            if usersLikedYouData.isEmpty {
                let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
                emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
                return emptyCell
            }else {
                cell.prepare(with: usersLikedYouData[indexPath.row])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if !switchButton.isOn {
            if matchedUserData.isEmpty {
                return collectionView.frame.size
            }else {
                let windowWidth = collectionView.frame.width - 40
                let cellWidth = windowWidth / 2
                return CGSize(width: cellWidth, height: cellWidth + 100)
            }
        }else {
            if usersLikedYouData.isEmpty {
                return collectionView.frame.size
            }else {
                let windowWidth = collectionView.frame.width - 40
                let cellWidth = windowWidth / 2
                return CGSize(width: cellWidth, height: cellWidth + 100)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var userData: User!
        if !switchButton.isOn {
            guard !matchedUserData.isEmpty else { return }
            userData = matchedUserData[indexPath.row]
        }else {
            guard !usersLikedYouData.isEmpty else { return }
            userData = usersLikedYouData[indexPath.row]
        }
        //moveToProfileDetailFromWhoLiked(data: userData, index: indexPath.row)
    } 
}

extension WhoLikedViewController: DiscoverCellDelegate {
    func likeTapped(at indexPath: IndexPath) {
        self.likeAction(indexPath: indexPath)
    }
    
    func superLikeTapped(at indexPath: IndexPath) {
        self.superLikeAction(indexPath: indexPath)
    }
    
    func dislikeTapped(at indexPath: IndexPath) {
        self.dislikeAndRemove(indexPath: indexPath)
    }
}
