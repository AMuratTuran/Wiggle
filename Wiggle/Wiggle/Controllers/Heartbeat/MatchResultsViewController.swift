//
//  MatchResultsViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 16.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class MatchResultsViewController: UIViewController {

    @IBOutlet weak var heartBeatLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var result: HeartRateKitResult?
    var data: [PFUser]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        getMatchData()
        addProductLogoToNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    func prepare() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.setGradientBackground()
        heartBeatLabel.text = "\(Int(result?.bpm ?? 0)) BPM"
        collectionView.register(UINib(nibName: HeartbeatMatchCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: HeartbeatMatchCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        initUpwardsAnimation()
    }
    
    func getMatchData() {
        startAnimating(self.view, startAnimate: true)
        NetworkManager.getHeartRateMatches(heartRate: Int(result?.bpm ?? 0), success: { (response) in
            self.startAnimating(self.view, startAnimate: false)
            self.startUpwardsAnimation()
            self.data = response
        }) { (error) in
            self.displayError(message: error)
        }
    }
    
    func initUpwardsAnimation() {
        collectionView.alpha = 0
        collectionView.transform = CGAffineTransform(translationX: 0, y: 50)
    }
    
    func startUpwardsAnimation() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseIn], animations: {
            self.collectionView.alpha = 1
            self.collectionView.transform = CGAffineTransform.identity
        })
    }
}

extension MatchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = data else { return 0 }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let data = data else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeartbeatMatchCell.reuseIdentifier, for: indexPath) as! HeartbeatMatchCell
        let profileImageHeroId = "profileImage\(indexPath.row)"
        let nameHeroId = "name\(indexPath.row)"
        let subLabelId = "subLabel\(indexPath.row)"
        let contentViewId = "contentView\(indexPath.row)"
        cell.imageView.hero.id = profileImageHeroId
        cell.nameAndAgeLabel.hero.id = nameHeroId
        cell.locationLabel.hero.id = subLabelId
        cell.prepare(with: data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let windowWidth = collectionView.frame.width - 40
        let cellWidth = windowWidth / 2
        return CGSize(width: cellWidth, height: cellWidth + 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = data else { return }
        moveToProfileDetailFromWhoLiked(data: data[indexPath.row], index: indexPath.row)
    }
}

