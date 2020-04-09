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
    var usersLikedYouData: [User]?
    private var superLikeCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSuperlikeCount()
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
    
    func getSuperlikeCount() {
        if let user = PFUser.current() {
            user.fetchInBackground(block: { (object, error) in
                if let error = error {
                    self.alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
                    return
                }
                guard let user = object as? PFUser else {
                    return
                }
                self.superLikeCount = user.object(forKey: "super_like") as! Int
            })
        }
    }
    
    func dislikeAndRemove(indexPath: IndexPath) {
        self.usersLikedYouData?.remove(at: indexPath.row)
        guard let receiver = self.usersLikedYouData?[indexPath.row].objectId else {return}
        guard self.likeDislikeAction(action: .dislike, receiver: receiver) else {return}
        
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
    }
    
    func superLikeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        guard let receiver = self.usersLikedYouData?[indexPath.row].objectId else {return}
        guard self.likeDislikeAction(action: .superlike, receiver: receiver) else {return}
        
        usersLikedYouData?[indexPath.row].isLiked = true
        _ = cell.playSuperLikeAnimation().done { _ in
            self.usersLikedYouData?.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func likeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        guard let receiver = self.usersLikedYouData?[indexPath.row].objectId else {return}
        guard self.likeDislikeAction(action: .like, receiver: receiver) else {return}
        
        usersLikedYouData?[indexPath.row].isLiked = true
        _ = cell.playLikeAnimation().done { _ in
            self.usersLikedYouData?.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func likeDislikeAction(action : ActionType, receiver : String) -> Bool{
        let cancelButton = DefaultButton(title: Localize.Common.CancelButton) {}
        let goToSuperLikeStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "SuperLikeInAppPurchaseViewController") as! SuperLikeInAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        let goToIAPStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        if action == .superlike && superLikeCount <= 0{
            self.alertMessage(message: Localize.HomeScreen.superLikeError, buttons: [goToSuperLikeStoreButton, cancelButton], isErrorMessage: true)
            return false
        }else if action == .superlike{
            superLikeCount -= 1
        }
        NetworkManager.swipeActionWithDirection(receiver: receiver, action: action, success: {
        }) { (err) in
            if err.contains("1006") && action != .dislike{
                self.alertMessage(message: Localize.HomeScreen.likeError, buttons: [goToIAPStoreButton, cancelButton], isErrorMessage: true)
            }
        }
        return true
    }
}


extension LikedYouViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = usersLikedYouData else { return 0 }
        
        if data.isEmpty {
            return 1
        }else {
            return data.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let data = usersLikedYouData, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCell.reuseIdentifier, for: indexPath) as? DiscoverCell else { return UICollectionViewCell() }
        //           let profileImageHeroId = "profileImage\(indexPath.row)"
        //           let nameHeroId = "name\(indexPath.row)"
        //           let subLabelId = "subLabel\(indexPath.row)"
        //           let contentViewId = "contentView\(indexPath.row)"
        //           cell.imageView.hero.id = profileImageHeroId
        //           cell.nameAndAgeLabel.hero.id = nameHeroId
        //           cell.locationLabel.hero.id = subLabelId
        if data.isEmpty {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
            emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
            return emptyCell
        }else {
            cell.prepare(with: data[indexPath.row])
            cell.delegate = self
            cell.indexPath = indexPath
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = usersLikedYouData else { return .zero }
        
        if data.isEmpty {
            return collectionView.frame.size
        }else {
            let windowWidth = collectionView.frame.width - 40
            let cellWidth = windowWidth / 2
            return CGSize(width: cellWidth, height: cellWidth + 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = usersLikedYouData else { return }
        var userData: User!
        
        guard !data.isEmpty else { return }
        userData = data[indexPath.row]
        
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
