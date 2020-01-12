//
//  InitialHeartbeatViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 13.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class InitialHeartbeatViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func startTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Heartbeat", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "GetHeartbeatViewController") as! GetHeartbeatViewController
        destinationVC.modalPresentationStyle = .fullScreen
        self.present(destinationVC, animated: true, completion: nil)
    }
    
}
