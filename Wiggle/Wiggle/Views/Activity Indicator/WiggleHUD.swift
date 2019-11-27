//
//  WiggleHUD.swift
//  Wiggle
//
//  Created by Murat Turan on 27.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class WiggleHUD: NVActivityIndicatorViewable {
    
    enum ProgressType {
        case none
        case progress
        case error
        case success

        var dismissable: Bool {
            return self == .error || self == .success
        }
    }

    static var currentType: ProgressType = .none
    static var withTimer: Bool = false
    static var activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), size: CGSize(width: 40.0, height: 40.0)), type: .ballClipRotate)
    
    class func show() {
        activityIndicator.startAnimating()
        currentType = .progress
        
    }
    
    class func showSuccessWithStatus(_ status: String!) {
        
        currentType = .success
    }
    
    class func showWithStatus(_ status: String) {
        currentType = .progress
    }
    
    class func dismiss() {
        
    }
    
}
