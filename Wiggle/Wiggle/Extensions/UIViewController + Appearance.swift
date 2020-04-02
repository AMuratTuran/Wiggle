//
//  UIViewController + Appearance.swift
//  Wiggle
//
//  Created by Murat Turan on 2.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setDefaultGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [AppConstants.Color.GradientBackgroundFirstColor.cgColor, AppConstants.Color.GradientBackgroundSecondColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.05)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.95)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}


