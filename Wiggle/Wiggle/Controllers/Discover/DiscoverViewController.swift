//
//  DiscoverViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 4.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import Lottie
import PopupDialog

class DiscoverViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data: [User] = []
    fileprivate var skipCount : Int = 0
    
    let animationView = AnimationView(name: "sensor_fingerprint")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
        getUsers()
    }
    
    func initializeViews() {
        setDefaultGradientBackground()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .white
        addMessageIconToNavigationBar()
        addProductLogoToNavigationBar(selector: nil, logoName: "", isItalicTitle: true)
        transparentNavigationBar()
        transparentTabBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: DiscoverCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: DiscoverCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        createLottieAnimation()
    }
    
    func getUsers() {
        NetworkManager.getDiscoveryUsers(withSkip: skipCount, success: { (users) in
            if users.count == 0 {
                self.animationView.isHidden = false
                self.animationView.play()
                let doneButton = DefaultButton(title: Localize.Common.OKButton) {
                    
                }
                self.alertMessage(message: Localize.HomeScreen.noUserError, buttons: [doneButton], isErrorMessage: true, isGestureDismissal: false)
            }else{
                self.animationView.pause()
                self.animationView.isHidden = true
                self.skipCount += 50
            }
            users.forEach { user in
                let userModel = User(parseUser: user)
                self.data.append(userModel)
            }
            DispatchQueue.main.async {
                delay(0.3) {
                    self.collectionView.reloadData()
                }
            }
        }) { fail in
            self.alertMessage(message: fail, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
        }
    }
    
    func createLottieAnimation() {
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        animationView.center = self.view.center
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        view.addSubview(animationView)
        animationView.play()
    }
    
    func dislikeAndRemove(indexPath: IndexPath) {
        self.data.remove(at: indexPath.row)
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
    }
    
    func superLikeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        data[indexPath.row].isLiked = true
        _ = cell.prepareSuperLike().done { _ in
            self.data.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func likeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        data[indexPath.row].isLiked = true
        _ = cell.prepareLike().done { _ in
            self.data.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCell.reuseIdentifier, for: indexPath) as? DiscoverCell else { return UICollectionViewCell() }
        
        //        let profileImageHeroId = "profileImage\(indexPath.row)"
        //        let nameHeroId = "name\(indexPath.row)"
        //        let subLabelId = "subLabel\(indexPath.row)"
        //        cell.imageView.hero.id = profileImageHeroId
        //        cell.nameAndAgeLabel.hero.id = nameHeroId
        //        cell.locationLabel.hero.id = subLabelId
        
        cell.prepare(with: data[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 40
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: cellWidth + 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // open profile
    }
}

extension DiscoverViewController: DiscoverCellDelegate {
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
