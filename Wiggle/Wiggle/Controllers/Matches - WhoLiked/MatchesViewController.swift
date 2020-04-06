//
//  MatchesViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 6.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class MatchesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var matchedUserData: [User] = []
    
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
    
}

extension MatchesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if matchedUserData.isEmpty {
            return 1
        }else {
            return matchedUserData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCell.reuseIdentifier, for: indexPath) as! DiscoverCell
        //        let profileImageHeroId = "profileImage\(indexPath.row)"
        //        let nameHeroId = "name\(indexPath.row)"
        //        let subLabelId = "subLabel\(indexPath.row)"
        //        let contentViewId = "contentView\(indexPath.row)"
        //        cell.imageView.hero.id = profileImageHeroId
        //        cell.nameAndAgeLabel.hero.id = nameHeroId
        //        cell.locationLabel.hero.id = subLabelId
        if matchedUserData.isEmpty {
            let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
            emptyCell.prepare(description: Localize.WhoLiked.NoMatchKeepLooking)
            return emptyCell
        }else {
            cell.prepare(with: matchedUserData[indexPath.row])
            cell.hideButtons()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if matchedUserData.isEmpty {
            return collectionView.frame.size
        }else {
            let windowWidth = collectionView.frame.width - 40
            let cellWidth = windowWidth / 2
            return CGSize(width: cellWidth, height: cellWidth + 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var userData: User!
        guard !matchedUserData.isEmpty else { return }
        userData = matchedUserData[indexPath.row]
        //moveToProfileDetailFromWhoLiked(data: userData, index: indexPath.row)
    }
}
