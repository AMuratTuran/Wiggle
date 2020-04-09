//
//  MatchesViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 6.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import PopupDialog

class MatchesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var matchedUserData: [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        getMatchData()
    }
    
    func prepareViews() {
        setDefaultGradientBackground()
        transparentNavigationBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        collectionView.register(UINib(nibName: DiscoverCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: DiscoverCell.reuseIdentifier)
        collectionView.register(UINib(nibName: EmptyCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier)
        
    }
    
    func getMatchData() {
        startAnimating(self.view, startAnimate: true)
        var data: [User] = []
        NetworkManager.getMatchedUsers(success: { (response) in
            self.startAnimating(self.view, startAnimate: false)
            response.forEach { user in
                let userModel = User(parseUser: user)
                data.append(userModel)
            }
            self.matchedUserData = data
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
    
    func dislikeAndRemove(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        guard let receiver = self.matchedUserData?[indexPath.row].objectId else {return}
        self.unmatch(receiverId: receiver)
        
        _ = cell.playDislikeAnimation().done { _ in
            self.matchedUserData?.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func unmatch(receiverId: String) {
        let cancelButton = DefaultButton(title: Localize.Common.Close) {
        }
        
        NetworkManager.unMatch(myId: AppConstants.objectId, contactedUserId: receiverId, success: {
            
        }) { (error) in
            self.alertMessage(message: error, buttons: [cancelButton], isErrorMessage: false)
        }
    }
}

extension MatchesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.matchedUserData else { return 0 }
        
        if data.isEmpty {
            return 1
        }else {
            return data.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let data = self.matchedUserData, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCell.reuseIdentifier, for: indexPath) as? DiscoverCell else { return UICollectionViewCell() }
        
        let profileImageHeroId = "profileImage\(indexPath.row)"
        let nameHeroId = "name\(indexPath.row)"
        let subLabelId = "subLabel\(indexPath.row)"
        cell.profileImageView.hero.id = profileImageHeroId
        cell.nameLabel.hero.id = nameHeroId
        cell.distanceLabel.hero.id = subLabelId
        
        if data.isEmpty {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
            emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
            return emptyCell
        }else {
            cell.prepare(with: data[indexPath.row])
            cell.hideButtons()
            cell.showDislikeButton()
            cell.indexPath = indexPath
            cell.delegate = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = self.matchedUserData else { return .zero }
        if data.isEmpty {
            return collectionView.frame.size
        }else {
            let windowWidth = collectionView.frame.width - 40
            let cellWidth = windowWidth / 2
            return CGSize(width: cellWidth, height: cellWidth + 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = matchedUserData else { return }
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let dest = storyboard.instantiateViewController(withIdentifier: "ProfileDetailViewController") as? ProfileDetailViewController else { return }
        dest.userData = data[indexPath.row]
        dest.isHeroEnabled = true
        dest.indexOfParentCell = indexPath
        dest.modalPresentationStyle = .fullScreen
        dest.isMatchesPages = true
        self.present(dest, animated: true, completion: nil)
    }
}

extension MatchesViewController: DiscoverCellDelegate {
    func likeTapped(at indexPath: IndexPath) {
        
    }
    
    func superLikeTapped(at indexPath: IndexPath) {
        
    }
    
    func dislikeTapped(at indexPath: IndexPath) {
        self.dislikeAndRemove(indexPath: indexPath)
    }
}
