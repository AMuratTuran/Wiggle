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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        createLottieAnimation()
        if isLoggedIn() {
            
        }
    }
    
    func createLottieAnimation() {
        let animationView = AnimationView(name: "heartbeat")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        view.addSubview(animationView)
        animationView.play()
        
        delay(2.0) {
            let homeStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = homeStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            //self.navigationController?.viewControllers.removeAll()
            self.navigationController?.pushViewController(destinationViewController, animated: true)
            
            //self.initializeMainTabBar()
        }
        
        
    }
    func isLoggedIn() -> Bool {
        if PFUser.current() != nil {
            return true
        }else {
            return false
        }
    }
    
}