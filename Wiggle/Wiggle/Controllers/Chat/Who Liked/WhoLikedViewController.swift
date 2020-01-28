//
//  WhoLikedViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 26.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class WhoLikedViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likedButton: UIButton!
    @IBOutlet weak var matchedButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var buttonShadowView: UIView!
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        getMatchData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        buttonShadowView.layer.applyShadow(color: UIColor(named: "shadowColor")!, alpha: 0.3, x: 0, y: 10, blur: 25, spread: 0)
    }
    
    func prepareViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
               collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        collectionView.register(UINib(nibName: HeartbeatMatchCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: HeartbeatMatchCell.reuseIdentifier)
        buttonsStackView.cornerRadius(25.0)
        buttonsStackView.clipsToBounds = true
        matchedButton.isSelected = true
        matchedButton.backgroundColor = .systemPink
        let image = UIImage(named: "icon_smartsearch_message")?.withRenderingMode(.alwaysTemplate)
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
        if likedYouData == nil {
            startAnimating(self.view, startAnimate: true)
            NetworkManager.getWhoLikedYou(success: { (response) in
                self.likedYouData = response
                self.getUserInfo()
            }) { (error) in
                self.startAnimating(self.view, startAnimate: false)
                self.displayError(message: error)
            }
        }else {
            collectionView.reloadData()
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
                    self.usersLikedYouData = collectionViewData
                }
            }) { (error) in
                
            }
        }
    }
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likedButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        matchedButton.isSelected = false
        likedButton.backgroundColor = .systemPink
        if #available(iOS 13.0, *) {
            matchedButton.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        getWhoLiked()
    }
    
    @IBAction func matchedButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        likedButton.isSelected = false 
        matchedButton.backgroundColor = .systemPink
        if #available(iOS 13.0, *) {
            likedButton.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        getMatchData()
    }
}

extension WhoLikedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if matchedButton.isSelected {
            guard let data = matchedUserData else { return 0 }
            return data.count
        }else {
            guard let data = usersLikedYouData else { return 0 }
            return data.count
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
        cell.shadowView?.hero.id = contentViewId
        if matchedButton.isSelected {
            guard let data = matchedUserData else { return UICollectionViewCell() }
            cell.prepare(with: data[indexPath.row])
        }else {
            guard let data = usersLikedYouData else { return UICollectionViewCell() }
            cell.prepare(with: data[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let windowWidth = collectionView.frame.width - 40
        let cellWidth = windowWidth / 2
        return CGSize(width: cellWidth, height: cellWidth + 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var userData: PFUser!
        if matchedButton.isSelected {
            guard let data = matchedUserData else { return }
            userData = data[indexPath.row]
        }else {
            guard let data = usersLikedYouData else { return }
            userData = data[indexPath.row]
        }
        
        moveToProfileDetailFromWhoLiked(data: userData, index: indexPath.row)
    }
}
