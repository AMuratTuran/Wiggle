//
//  HeartbeatView.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 22.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Lottie

class HeartbeatView: UIView {
    
    public func createLottieAnimation() {
        let animationView = AnimationView(name: "heartbeat")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.center
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        self.addSubview(animationView)
        animationView.play()
        
//        delay(2.0) {
//            guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//            delegate.initializeWindow()
//        }
    }
    
}
class Heartbeat : HeartbeatViewComponent{
    
    public weak var view: HeartbeatView!
    
    override public func componentDidLoad() {
        if let componentView = super.componentView as? HeartbeatView {
            view = componentView
            view.createLottieAnimation()
        }
    }
}
