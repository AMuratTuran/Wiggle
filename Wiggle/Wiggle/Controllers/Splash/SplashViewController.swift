//
//  SplashViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 27.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import Lottie

class SplashViewController: UIViewController {
    
    var isLaunchedFromPN: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        createLottieAnimation()
        if isLoggedIn() {
            delay(2.0) {
                guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                delegate.initializeWindow(isLaunchedFromPN: self.isLaunchedFromPN)
            }
        }
    }
    
    func createLottieAnimation() {
        let animationView = AnimationView(name: "heartbeat")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        //view.addSubview(animationView)
        //animationView.play()
    }
    
    func isLoggedIn() -> Bool {
        if let user = PFUser.current() {
            User.current = User(parseUser: user)
            return true
        }else {
            return false
        }
    }
}
