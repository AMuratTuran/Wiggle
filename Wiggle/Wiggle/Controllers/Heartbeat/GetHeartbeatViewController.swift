//
//  GetHeartbeatViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 13.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Lottie
import AVFoundation

class GetHeartbeatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLottieAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        calculateHeartbeat()
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
        //toggleFlash()
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    
                } catch {
                    print(error)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    func calculateHeartbeat() {
        let controller = HeartRateKitController()
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //toggleFlash()
    }
}

extension GetHeartbeatViewController: HeartRateKitControllerDelegate {
    func heartRateKitController(_ controller: HeartRateKitController, didFinishWith result: HeartRateKitResult) {
        print(result)
    }
    
    func heartRateKitControllerDidCancel(_ controller: HeartRateKitController) {
        self.dismiss(animated: true, completion: nil)
    }
}
