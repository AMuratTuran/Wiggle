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
    @IBOutlet weak var emptyImage: UIImageView!
    
    public func createLottieAnimation() {
        let animationView = AnimationView(name: "heartbeat")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.center
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        self.addSubview(animationView)
        animationView.play()
    }
    
}

public struct HeartbeatModel{
    public var image : String?
    
    public init(image : String){
        self.image = image
    }
    public init (){}
}

class Heartbeat : HeartbeatViewComponent{
    
    public weak var view: HeartbeatView!
    public var model : HeartbeatModel?{
        didSet{
            updateUI()
        }
    }
    
    override public func componentDidLoad() {
        if let componentView = super.componentView as? HeartbeatView {
            view = componentView
//            view.createLottieAnimation()
        }
    }
    
    public func updateUI(){
        view.emptyImage.cornerRadius(12)
        //view.emptyImage.image = UIImage(named: model?.image ?? "")
    }
    
}
