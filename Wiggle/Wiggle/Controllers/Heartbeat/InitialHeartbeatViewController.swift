//
//  InitialHeartbeatViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 13.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class InitialHeartbeatViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var result: HeartRateKitResult?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
    }
    
    func initializeViews() {
        hideBackBarButtonTitle()
        transparentTabBar()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.setGradientBackground()
                
        startButton.setTitle(Localize.Common.Start, for: .normal)
        startButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        titleLabel.text = Localize.Heartbeat.Title
        instructionLabel.text = Localize.Heartbeat.PlaceFinger
    }
    
    @IBAction func startTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Heartbeat", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "GetHeartbeatViewController") as! GetHeartbeatViewController
        destinationVC.delegate = self
        destinationVC.modalPresentationStyle = .fullScreen
        self.present(destinationVC, animated: true, completion: nil)
    }
    
    func moveToMatchResults() {
        guard let result = result, let _ = PFUser.current() else { return }
        DispatchQueue.main.async {
            self.startAnimating(self.view, startAnimate: true)
            PFUser.current()?.setValue(Int(result.bpm), forKey: "beat")
            PFUser.current()?.saveInBackground(block: { (response, error) in
                self.startAnimating(self.view, startAnimate: false)
                if error != nil {
                    self.displayError(message: error?.localizedDescription ?? "")
                }else {
                    self.moveToMatchResultsViewController(result: result)
                }
            })
        }
    }
}

extension InitialHeartbeatViewController: HeartRateDelegate {
    func didCompleteWithResult(result: HeartRateKitResult) {
        self.result = result
        moveToMatchResults()
    }
    
    func didCancelHeartRate() {
        
    }
    
    
}
