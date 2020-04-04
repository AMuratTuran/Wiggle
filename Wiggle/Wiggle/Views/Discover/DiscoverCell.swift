//
//  DiscoverCell.swift
//  Wiggle
//
//  Created by Murat Turan on 4.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import Lottie

protocol DiscoverCellDelegate {
    func likeTapped(at indexPath: IndexPath)
    func dislikeTapped(at indexPath: IndexPath)
}
class DiscoverCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var data: User?
    var delegate: DiscoverCellDelegate?
    var indexPath: IndexPath?
    var isLiked: Bool = false {
        didSet {
            if isLiked {
                prepareLike()
            }
        }
    }
    var isSuperliked: Bool = false {
        didSet {
            if isSuperliked {
                prepareSuperLike()
            }
        }
    }
    
    var likeAnimationView: AnimationView?
    
    override var isHighlighted: Bool {
        didSet {
            shrink(down: isHighlighted)
        }
    }
    
    func shrink(down: Bool) {
      UIView.animate(withDuration: 0.3) {
        if down {
            self.containerView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            self.containerView?.transform = .identity
        }
      }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeViews()
    }

    func initializeViews() {
        containerView.cornerRadius(25)
        containerView.clipsToBounds = true
        
        dislikeButton.cornerRadius(dislikeButton.frame.height / 2)
        dislikeButton.setWhiteGradient()
        
        likeButton.cornerRadius(likeButton.frame.height / 2)
        likeButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        blurView.alpha = 0
        likeButton.isHidden = false
        dislikeButton.isHidden = false
        likeAnimationView = AnimationView(name: "like")
        createLikeAnimation()
    }
    
    func createLikeAnimation() {
        likeAnimationView?.isHidden = true
        
        likeAnimationView?.loopMode = .playOnce
        likeAnimationView?.contentMode = .scaleAspectFill
        likeAnimationView?.animationSpeed = 1
        
        containerView.addSubview(likeAnimationView ?? UIView())
        
        NSLayoutConstraint.activate([
            likeAnimationView!.widthAnchor.constraint(equalToConstant: 80),
            likeAnimationView!.heightAnchor.constraint(equalToConstant: 80),
            likeAnimationView!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            likeAnimationView!.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func prepare(with data: User) {
        self.data = data
        self.isLiked = data.isLiked
        containerView.addBorder(UIColor(hexString: "D9B372"), width: 0.5)
        
        if let imageUrl = data.image {
            profileImageView.kf.setImage(with: URL(string: imageUrl))
            profileImageView.kf.indicatorType = .activity
        }else {
            profileImageView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }
        
        let age = "\(data.age ?? 0)"
        let name = "\(data.firstName) \(data.lastName)"
        nameLabel.text = "\(name), \(age)"
        distanceLabel.text = "\(String(format: "%.1f", getDistance())) km"
        
        blurView.alpha = isLiked || isSuperliked ? 0.2 : 0
        likeButton.isHidden = isLiked || isSuperliked
        dislikeButton.isHidden = isLiked || isSuperliked
        likeAnimationView?.isHidden = !isLiked
    }
    
    func prepareLike() {
        likeAnimationView?.isHidden = false
        self.likeButton.isHidden = true
        self.dislikeButton.isHidden = true
        likeAnimationView?.play(completion: { _ in
            self.blurView.backgroundColor = UIColor.systemPink
            self.containerView.addBorder(UIColor.systemPink, width: 0.5)
            self.blurView.alpha = 0.2
        })
    }
    
    func prepareSuperLike() {
        likeButton.isHidden = true
        dislikeButton.isHidden = true
        blurView.backgroundColor = UIColor(hexString: "D9B372")
        containerView.addBorder(UIColor(hexString: "D9B372"), width: 0.5)
        blurView.alpha = 0.2
    }
    
    func getDistance() -> Double {
        if let user = User.current, let data = self.data {
            let myLocation = CLLocation(latitude: user.latitude ?? 0, longitude: user.longitude ?? 0)
            let userLocation = CLLocation(latitude: data.latitude ?? 0, longitude: data.longitude ?? 0 )
            let distanceInMeters = myLocation.distance(from: userLocation)
            let distanceInKm = distanceInMeters / 1000
            return Double(distanceInKm)
        }else {
            return 0
        }
    }
    @IBAction func dislikeButtonTapped(_ sender: Any) {
        if let indexPath = self.indexPath {
            delegate?.dislikeTapped(at: indexPath)
        }
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        if let indexPath = self.indexPath {
            delegate?.likeTapped(at: indexPath)
        }
    }
}
