//
//  OnboardingDoubleTapViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Lottie
import PromiseKit

class OnboardingDoubleTapViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var doubleTapAnimationView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.createDoubleTapAnimation()
        }
    }

    func prepareViews() {
        setDefaultGradientBackground()
        transparentNavigationBar()
        hideBackBarButtonTitle()
        self.navigationController?.navigationBar.tintColor = .white
        doubleTapAnimationView = AnimationView(name: "doubleTap")
        descriptionLabel.text = Localize.Onboarding.DoubleTapDesc
        nextButton.title = Localize.Common.Next
    }
    
    func createDoubleTapAnimation() {
        doubleTapAnimationView?.isHidden = true
        doubleTapAnimationView?.frame = containerView.frame
        doubleTapAnimationView?.loopMode = .loop
        doubleTapAnimationView?.contentMode = .scaleAspectFit
        doubleTapAnimationView?.animationSpeed = 1
        
        doubleTapAnimationView?.frame = containerView.frame
        doubleTapAnimationView?.frame.origin.x = containerView.frame.origin.x
        doubleTapAnimationView?.frame.origin.y = containerView.frame.origin.y
        containerView.addSubview(doubleTapAnimationView ?? UIView())
//
//        NSLayoutConstraint.activate([
//            doubleTapAnimationView!.widthAnchor.constraint(equalToConstant: view.frame.width),
//            doubleTapAnimationView!.heightAnchor.constraint(equalToConstant: view.frame.height),
//            doubleTapAnimationView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            doubleTapAnimationView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            doubleTapAnimationView!.topAnchor.constraint(equalTo: view.topAnchor)
//        ])
        
        _ = self.playDoubleTapAnimation()
        
    }
    
    func playDoubleTapAnimation() -> Promise<()> {
        return Promise { seal in
            doubleTapAnimationView?.isHidden = false
            self.doubleTapAnimationView?.play(completion: { _ in
                seal.fulfill_()
            })
        }
    }
    @IBAction func nextButtonAction(_ sender: Any) {
        
    }
}
