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
    var data: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        getMatchData()
    }
    
    func prepare() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .white
        transparentNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: FontHelper.bold(18)]
        setDefaultGradientBackground()
        
        heartBeatLabel.text = "\(Int(result?.bpm ?? 0)) BPM"
        
        collectionView.register(UINib(nibName: DiscoverCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: DiscoverCell.reuseIdentifier)
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
            
            response.forEach { user in
                let userModel = User(parseUser: user)
                self.data.append(userModel)
            }
            
            DispatchQueue.main.async {
                delay(0.3) {
                    self.collectionView.reloadData()
                }
            }
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
        _ = cell.playSuperLikeAnimation().done { _ in
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
        _ = cell.playLikeAnimation().done { _ in
            self.data.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func disableVisibleCells() {
        self.collectionView.visibleCells.forEach {
            $0.isUserInteractionEnabled = false
        }
    }
    
    func enableVisibleCells() {
        self.collectionView.visibleCells.forEach {
            $0.isUserInteractionEnabled = true
        }
    }
}

extension MatchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
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
        cell.isUserInteractionEnabled = true
        cell.prepare(with: data[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let windowWidth = collectionView.frame.width - 40
        let cellWidth = windowWidth / 2
        return CGSize(width: cellWidth, height: cellWidth + 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !data.isEmpty else { return }
        //moveToProfileDetailFromWhoLiked(data: data[indexPath.row], index: indexPath.row)
    }
}

extension MatchResultsViewController: DiscoverCellDelegate {
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
