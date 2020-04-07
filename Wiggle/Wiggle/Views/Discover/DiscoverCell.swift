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
    func superLikeTapped(at indexPath: IndexPath)
    func dislikeTapped(at indexPath: IndexPath)
    func likeTapped(at indexPath: IndexPath)
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
    
    var likeAnimationView: AnimationView?
    var superLikeAnimationView: AnimationView?
    var dislikeAnimationView: AnimationView?
    var confettiLayer: CAEmitterLayer?
    
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
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(likeAction))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delaysTouchesBegan = true
        doubleTapGesture.cancelsTouchesInView = true
        contentView.addGestureRecognizer(doubleTapGesture)
        
        dislikeButton.cornerRadius(dislikeButton.frame.height / 2)
        dislikeButton.setWhiteGradient()
        
        superLikeButton.cornerRadius(superLikeButton.frame.height / 2)
        superLikeButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        blurView.alpha = 0
        superLikeButton.isHidden = false
        dislikeButton.isHidden = false
        likeAnimationView = AnimationView(name: "like")
        superLikeAnimationView = AnimationView(name: "superlike")
        dislikeAnimationView = AnimationView(name: "dislike")
        DispatchQueue.main.async {
            self.createLikeAnimation()
            self.createSuperLikeAnimation()
            self.createDislikeAnimation()
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
    
    func createSuperLikeAnimation() {
        superLikeAnimationView?.isHidden = true
        superLikeAnimationView?.frame = containerView.frame
        superLikeAnimationView?.loopMode = .playOnce
        superLikeAnimationView?.contentMode = .scaleAspectFit
        superLikeAnimationView?.animationSpeed = 1
        
        containerView.addSubview(superLikeAnimationView ?? UIView())
        
        NSLayoutConstraint.activate([
            superLikeAnimationView!.widthAnchor.constraint(equalToConstant: containerView.frame.width),
            superLikeAnimationView!.heightAnchor.constraint(equalToConstant: containerView.frame.height),
            superLikeAnimationView!.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            superLikeAnimationView!.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
    }
    
    func createDislikeAnimation() {
        dislikeAnimationView?.isHidden = true
        dislikeAnimationView?.frame = containerView.frame
        dislikeAnimationView?.loopMode = .playOnce
        dislikeAnimationView?.contentMode = .scaleAspectFit
        dislikeAnimationView?.animationSpeed = 1.5
        
        containerView.addSubview(dislikeAnimationView ?? UIView())
        
        NSLayoutConstraint.activate([
            dislikeAnimationView!.widthAnchor.constraint(equalToConstant: containerView.frame.width),
            dislikeAnimationView!.heightAnchor.constraint(equalToConstant: containerView.frame.height),
            dislikeAnimationView!.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dislikeAnimationView!.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
    }
    
    func createBoostView() {
        if confettiLayer == nil {
            self.confettiLayer = Confetti.prepare(width: self.containerView.frame.width)
            if let confettiLayer = self.confettiLayer {
                self.containerView.layer.addSublayer(confettiLayer)
            }
            confettiLayer?.isHidden = true
        }
    }
        
    func prepare(with data: User) {
        self.data = data
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
        
        confettiLayer?.isHidden = true
        blurView.alpha = 0
        superLikeButton.isHidden = false
        dislikeButton.isHidden = false
        likeAnimationView?.isHidden = true
        superLikeAnimationView?.isHidden = true
        dislikeAnimationView?.isHidden = true
    }
    
    func playSuperLikeAnimation() -> Promise<()> {
        return Promise { seal in
            self.superLikeAnimationView?.isHidden = false
            self.superLikeButton.isHidden = true
            self.dislikeButton.isHidden = true
            self.blurView.backgroundColor = UIColor(hexString: "D9B372")
            self.containerView.addBorder(UIColor(hexString: "D9B372"), width: 1)
            self.blurView.alpha = 0.2
            self.superLikeAnimationView?.play(completion: { _ in
                seal.fulfill_()
            })
        }
    }
        
    func playLikeAnimation() -> Promise<()> {
        return Promise { seal in
            self.likeAnimationView?.isHidden = false
            self.superLikeButton.isHidden = true
            self.dislikeButton.isHidden = true
            self.blurView.backgroundColor = UIColor.systemPink
            self.containerView.addBorder(UIColor.systemPink, width: 1)
            self.blurView.alpha = 0.2
            self.likeAnimationView?.play(completion: { _ in
                seal.fulfill_()
            })
        }
    }
    
    func playDislikeAnimation() -> Promise<()> {
        return Promise { seal in
            self.dislikeAnimationView?.isHidden = false
            self.superLikeButton.isHidden = true
            self.dislikeButton.isHidden = true
            self.blurView.backgroundColor = UIColor.systemRed
            self.containerView.addBorder(UIColor.systemRed, width: 1)
            self.blurView.alpha = 0.2
            self.dislikeAnimationView?.play(completion: { _ in
                seal.fulfill_()
            })
        }
    }
    
    @objc func likeAction() {
        if let indexPath = self.indexPath {
            delegate?.likeTapped(at: indexPath)
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
    
    @IBAction func superLikeTapped(_ sender: Any) {
        if let indexPath = self.indexPath {
            delegate?.superLikeTapped(at: indexPath)
        }
    }
}

// Helpers
extension DiscoverCell {
    func showDislikeButton() {
        dislikeButton.isHidden = false
    }
    
    func hideDislikeButton() {
        dislikeButton.isHidden = true
    }
    
    func showSuperLikeButton() {
        superLikeButton.isHidden = false
    }
    
    func hideSuperLikeButton() {
        superLikeButton.isHidden = true
    }
    
    func showButtons() {
        showDislikeButton()
        showSuperLikeButton()
    }
    
    func hideButtons() {
        hideDislikeButton()
        hideSuperLikeButton()
    }
    
    func showBoostView() {
        confettiLayer?.isHidden = false
    }
    
    func hideBoostView() {
        confettiLayer?.isHidden = true
    }
}
