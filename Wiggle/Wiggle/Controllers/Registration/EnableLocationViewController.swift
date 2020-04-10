//
//  EnableLocationViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 21.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import PopupDialog

class EnableLocationViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enableButton: UIButton!
    
    let locationManager = CLLocationManager()
    var registerRequest: RegisterRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    func prepareViews() {
        self.view.setGradientBackground()
        
        enableButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        enableButton.setTitle(Localize.EnableLocation.EnableButton, for: .normal)
        
        topLabel.text = Localize.EnableLocation.EnableLocation
        descriptionLabel.text = Localize.EnableLocation.Description
    }
    
    func registerUser() {
        if let request = self.registerRequest {
            PFUser.current()?.setValue(request.firstName, forKey: "first_name")
            PFUser.current()?.setValue(request.lastName, forKey: "last_name")
            PFUser.current()?.setValue(request.bio, forKey: "bio")
            PFUser.current()?.setValue(request.gender, forKey: "gender")
            PFUser.current()?.setValue(request.birthday, forKey: "birthday")
            PFUser.current()?.setValue(5, forKey: "super_like")
            PFUser.current()?.setValue("false", forKey: "isGold")
            
            if let lat = request.latitude, let long = request.longtitude {
                let point = PFGeoPoint(latitude: lat, longitude: long)
                PFUser.current()?.setValue(point, forKey: "location")
            }
            
            if let imageData = request.image {
                do {
                    let imageFile: PFFileObject = PFFileObject(name:"image.jpg", data: imageData as Data)!
                    try imageFile.save()
                    PFUser.current()?.setObject(imageFile, forKey: "photo")
                }catch {
                    
                }
            }
            
            PFUser.current()?.saveInBackground(block: { (result, error) in
                self.enableButton.isUserInteractionEnabled = true
                self.startAnimating(self.view, startAnimate: false)
                if let error = error  {
                    self.alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
                }else {
                    self.moveToEnableNotificationsViewController()
                }
            })
        }else {
            alertMessage(message: Localize.Error.Generic, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
        }
    }
    
    @IBAction func enableLocation(_ sender: UIButton) {
        startAnimating(self.view, startAnimate: true)
        locationManager.delegate = self
        sender.isUserInteractionEnabled = false
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }else {
            registerUser()
        }
    }
}

extension EnableLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        registerRequest?.latitude = locValue.latitude
        registerRequest?.longtitude = locValue.longitude
        registerUser()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        startAnimating(self.view, startAnimate: false)
        enableButton.isUserInteractionEnabled = true
        alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
    }
}
