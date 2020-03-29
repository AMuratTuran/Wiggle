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

class EnableLocationViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enableButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareViews()
    }
    func prepareViews() {
        self.view.setGradientBackground()
        enableButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        enableButton.setTitle(Localize.EnableLocation.EnableButton, for: .normal)
        topLabel.text = Localize.EnableLocation.EnableLocation
        descriptionLabel.text = Localize.EnableLocation.Description
    }
    
    @IBAction func enableLocation(_ sender: UIButton) {
        startAnimating(self.view, startAnimate: true)
        locationManager.delegate = self
        sender.isUserInteractionEnabled = false
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
    }
}

extension EnableLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        PFUser.current()?.setValue(point, forKey: "location")
        PFUser.current()?.saveInBackground(block: { (result, error) in
            self.enableButton.isUserInteractionEnabled = true
            self.startAnimating(self.view, startAnimate: false)
            if error != nil {
                self.displayError(message: error?.localizedDescription ?? "")
            }else {
                self.moveToEnableNotificationsViewController(navigationController: self.navigationController ?? UINavigationController())
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.startAnimating(self.view, startAnimate: false)
        self.enableButton.isUserInteractionEnabled = true
        print(error.localizedDescription)
    }
}
