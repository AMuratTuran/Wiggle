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
import PromiseKit

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
    @IBOutlet weak var superLikeButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var data: User?
    var delegate: DiscoverCellDelegate?
    var indexPath: IndexPath?
    var isLiked: Bool = false
    var isSuperliked: Bool = false
    
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
        
        superLikeButton.cornerRadius(superLikeButton.frame.height / 2)
        superLikeButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        blurView.alpha = 0
        superLikeButton.isHidden = false
        dislikeButton.isHidden = false
        likeAnimationView = AnimationView(name: "superlike")
        DispatchQueue.main.async {
            self.createLikeAnimation()
        }
    }
    
    func createLikeAnimation() {
        likeAnimationView?.isHidden = true
        likeAnimationView?.frame = containerView.frame
        likeAnimationView?.loopMode = .playOnce
        likeAnimationView?.contentMode = .scaleAspectFit
        likeAnimationView?.animationSpeed = 1
        
        containerView.addSubview(likeAnimationView ?? UIView())
        
        NSLayoutConstraint.activate([
            likeAnimationView!.widthAnchor.constraint(equalToConstant: containerView.frame.width),
            likeAnimationView!.heightAnchor.constraint(equalToConstant: containerView.frame.height),
            likeAnimationView!.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            likeAnimationView!.topAnchor.constraint(equalTo: containerView.topAnchor)
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
        superLikeButton.isHidden = isLiked || isSuperliked
        dislikeButton.isHidden = isLiked || isSuperliked
        likeAnimationView?.isHidden = !isLiked
    }
    
    func prepareSuperLike() -> Promise<()> {
        return Promise { seal in
            self.likeAnimationView?.isHidden = false
            self.superLikeButton.isHidden = true
            self.dislikeButton.isHidden = true
            self.likeAnimationView?.play(completion: { _ in
                self.blurView.backgroundColor = UIColor(hexString: "D9B372")
                self.containerView.addBorder(UIColor(hexString: "D9B372"), width: 1)
                self.blurView.alpha = 0.2
                seal.fulfill_()
            })
        }
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
