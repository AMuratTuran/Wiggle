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
    
    var result: HeartRateKitResult?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        hideBackBarButtonTitle()
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
