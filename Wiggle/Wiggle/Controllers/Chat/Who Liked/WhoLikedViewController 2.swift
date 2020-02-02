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
    
    
    var matchedUserData: [PFUser]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        getMatchData()
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
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeartbeatMatchCell.reuseIdentifier, for: indexPath) as! HeartbeatMatchCell
        
        if matchedButton.isSelected {
            guard let data = matchedUserData else { return UICollectionViewCell() }
            cell.prepare(with: data[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let windowWidth = collectionView.frame.width - 20
        let cellWidth = windowWidth / 2
        return CGSize(width: cellWidth, height: cellWidth + 70)
    }
}
