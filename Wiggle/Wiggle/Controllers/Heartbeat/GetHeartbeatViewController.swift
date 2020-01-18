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

enum CurrentState {
    case Paused
    case Sampling
}

protocol HeartRateDelegate {
    func didCompleteWithResult(result: HeartRateKitResult)
    func didCancelHeartRate()
}

class GetHeartbeatViewController: UIViewController {
    // MARK: Heartbeat variables
    var shouldAbortAfterSeconds:Int = 20
    var timeToDetermineBPMFinalResultInSeconds:Double = 0.5
    
    // MARK: AVFoundation variables
    var session: AVCaptureSession?
    var videoDevice: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var frameOutput: AVCaptureVideoDataOutput?
    var delegate:HeartRateDelegate?
    var algorithm: HeartRateKitAlgorithm?
    var algorithmStartTime: Date?
    var bpmFinalResultFirstTimeDetected: Date?
    var result = HeartRateKitResult.create()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        resetAlgorithm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        prepare()
        createLottieAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stopRunningSession()
    }
    
    
    func prepare() {
        algorithm = HeartRateKitAlgorithm()
        algorithm?.windowSize = 9
        algorithm?.filterWindowSize = 45
        
        algorithmStartTime = Date()
        bpmFinalResultFirstTimeDetected = Date()
        
        session = AVCaptureSession()
        session?.sessionPreset = .cif352x288
        videoDevice = AVCaptureDevice.default(for: .video)
        guard let session = session, let videoDevice = videoDevice else { return }
        do{
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        }catch {
            
        }
        guard let videoInput = videoInput else { return }
        session.addInput(videoInput)
        frameOutput = AVCaptureVideoDataOutput()
        frameOutput?.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: Int32(kCVPixelFormatType_32BGRA))]
        frameOutput?.alwaysDiscardsLateVideoFrames = false
        let queue = DispatchQueue(label: "com.Wiggle.videoQueue")
        frameOutput?.setSampleBufferDelegate(self, queue: queue)
        guard let frameOutput = frameOutput else { return }
        session.addOutput(frameOutput)
        
        startRunningSession()
    }
    
    @objc func applicationWillEnterForeground() {
        if isViewLoaded, let _ = self.view.window {
            resetAlgorithm()
        }
    }
    
    @objc func applicationEnteredForeground() {
        if isViewLoaded, let _ = self.view.window {
            
        }
    }
    
    @objc func applicationEnteredBackground() {
        if isViewLoaded, let _ = self.view.window {
            stopRunningSession()
        }
    }
    
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnteredForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func startRunningSession() {
        session?.startRunning()
        toggleFlash()
    }
    
    func stopRunningSession() {
        session?.stopRunning()
        toggleFlash()
    }
    
    func resetAlgorithm() {
        algorithmStartTime = nil
        bpmFinalResultFirstTimeDetected = nil
        algorithm = nil
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
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        self.videoDevice = device
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
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return UIImage() }
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly);
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        // Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(imageBuffer);
        let height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage();
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly);
        
        // Create an image object from the Quartz image
        let image = UIImage.init(cgImage: quartzImage!);
        
        return image;
        
    }
    
    func dismissWithResult(result: HeartRateKitResult) {
        self.delegate?.didCompleteWithResult(result: result)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension GetHeartbeatViewController: HeartRateKitControllerDelegate {
    func heartRateKitController(_ controller: HeartRateKitController, didFinishWith result: HeartRateKitResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func heartRateKitControllerDidCancel(_ controller: HeartRateKitController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension GetHeartbeatViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if algorithm == nil {
            algorithm = HeartRateKitAlgorithm()
            algorithm?.windowSize = 9
            algorithm?.filterWindowSize = 45
            algorithmStartTime = Date()
            bpmFinalResultFirstTimeDetected = Date()
        }
        
        let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        let dominantColor = image.hrkAverageColorPrecise()
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        dominantColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = red * 255
        green = green * 255
        blue = blue * 255
        
        guard let color = dominantColor else { return }
        algorithm?.newFrameDetected(withAverageColor: color)
        
        if algorithm?.isFinalResultDetermined ?? false {
            if timeToDetermineBPMFinalResultInSeconds <= Date().timeIntervalSince(bpmFinalResultFirstTimeDetected ?? Date()) {
                result.markBPM(algorithm?.bpmLatestResult ?? 0)
                dismissWithResult(result: result)
                self.algorithm = nil
            }
        }
        
        if red < 180 {
            if shouldAbortAfterSeconds > 0  {
                if Int(Date().timeIntervalSince(algorithmStartTime ?? Date())) > shouldAbortAfterSeconds {
                    if algorithm?.isFinalResultDetermined ?? false {
                        result.markBPM(algorithm?.bpmLatestResult ?? 0)
                        dismissWithResult(result: result)
                        self.algorithm = nil
                        self.algorithmStartTime = nil
                        self.bpmFinalResultFirstTimeDetected = nil
                        return
                    }
                }
            }else {
                if algorithm?.isFinalResultDetermined ?? false {
                    result.markBPM(algorithm?.bpmLatestResult ?? 0)
                    dismissWithResult(result: result)
                    self.algorithm = nil
                    self.algorithmStartTime = nil
                    self.bpmFinalResultFirstTimeDetected = nil
                    return
                }
            }
            self.algorithm = nil
            self.algorithmStartTime = nil
            self.bpmFinalResultFirstTimeDetected = nil
            return
        }
    }
}
