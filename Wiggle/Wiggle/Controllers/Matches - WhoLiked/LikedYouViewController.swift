//
//  LikedYouViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 6.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import PopupDialog

class LikedYouViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var likedYouData: [PFObject]?
    var usersLikedYouData: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        getWhoLiked()
    }
    
    func prepareViews() {
        setDefaultGradientBackground()
        transparentNavigationBar()
        navigationController?.navigationBar.tintColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        collectionView.register(UINib(nibName: DiscoverCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: DiscoverCell.reuseIdentifier)
        collectionView.register(UINib(nibName: EmptyCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier)
    }
    
    func getWhoLiked() {
        if PFUser.current() != nil {
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
                    //self.switchToMatchScreen()
                })
            }
            let goToMatchScreen = DefaultButton(title: Localize.Common.Back) {
                //self.switchToMatchScreen()
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
                    DispatchQueue.main.async {
                        delay(0.3) {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }) { (error) in
                self.startAnimating(self.view, startAnimate: false)
            }
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


extension LikedYouViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if usersLikedYouData.isEmpty {
            return 1
        }else {
            return usersLikedYouData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCell.reuseIdentifier, for: indexPath) as! DiscoverCell
        //           let profileImageHeroId = "profileImage\(indexPath.row)"
        //           let nameHeroId = "name\(indexPath.row)"
        //           let subLabelId = "subLabel\(indexPath.row)"
        //           let contentViewId = "contentView\(indexPath.row)"
        //           cell.imageView.hero.id = profileImageHeroId
        //           cell.nameAndAgeLabel.hero.id = nameHeroId
        //           cell.locationLabel.hero.id = subLabelId
        if usersLikedYouData.isEmpty {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
            emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
            return emptyCell
        }else {
            cell.prepare(with: usersLikedYouData[indexPath.row])
            cell.delegate = self
            cell.indexPath = indexPath
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if usersLikedYouData.isEmpty {
            return collectionView.frame.size
        }else {
            let windowWidth = collectionView.frame.width - 40
            let cellWidth = windowWidth / 2
            return CGSize(width: cellWidth, height: cellWidth + 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var userData: User!
        
        guard !usersLikedYouData.isEmpty else { return }
        userData = usersLikedYouData[indexPath.row]
        
        //moveToProfileDetailFromWhoLiked(data: userData, index: indexPath.row)
    }
}

extension LikedYouViewController: DiscoverCellDelegate {
    func superLikeTapped(at indexPath: IndexPath) {
        self.superLikeAction(indexPath: indexPath)
    }
    
    func dislikeTapped(at indexPath: IndexPath) {
        self.dislikeAndRemove(indexPath: indexPath)
    }
    
    func likeTapped(at indexPath: IndexPath) {
       self.likeAction(indexPath: indexPath)
    }
    
    
}
