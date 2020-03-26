//
//  HeartbeatMatchCell.swift
//  Wiggle
//
//  Created by Murat Turan on 16.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class HeartbeatMatchCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var containerView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    
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
    
    override func draw(_ rect: CGRect) {
        prepare()
    }
    
    func prepare() {
    }
    
    func prepare(with data: PFUser) {
        let imageUrl = data.getPhotoUrl()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: imageUrl))
        let age = "\(data.getAge())"
        let name = "\(data.getFirstName()) \(data.getLastName())"
        nameAndAgeLabel.text = "\(name), \(age)"
        locationLabel.text = "\(String(format: "%.1f", getDistance(with: data))) km"
    }
    
    func getDistance(with data: PFUser) -> Double {
        if let user = PFUser.current() {
            let myLocation = CLLocation(latitude: user.getLocation().latitude, longitude: user.getLocation().longitude)
            let userLocation = CLLocation(latitude: data.getLocation().latitude, longitude: data.getLocation().longitude)
            let distanceInMeters = myLocation.distance(from: userLocation)
            let distanceInKm = distanceInMeters / 1000
            return Double(distanceInKm)
        }else {
            return 0
        }
    }
}
