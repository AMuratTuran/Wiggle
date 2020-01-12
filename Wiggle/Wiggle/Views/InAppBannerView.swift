//
//  InAppBannerView.swift
//  Wiggle
//
//  Created by Murat Turan on 4.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import SwiftMessages

class InAppBannerView: MessageView {
    
    @IBOutlet weak var headerView: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        prepareViews()
    }
    
    func prepareViews() {
        headerView.addShadow()
    }
    
    func configure(title: String, body: String) {
        headerView.text = title
        alertLabel.text = body
    }
    @IBAction func bannerTapped(_ sender: Any) {
        SwiftMessages.hide()
        
    }
}


