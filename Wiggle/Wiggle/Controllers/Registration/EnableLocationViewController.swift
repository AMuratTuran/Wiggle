//
//  EnableLocationViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 21.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import CoreLocation

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
        
    }
    
    @IBAction func enableLocation(_ sender: UIButton) {
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            moveToEnableNotificationsViewController(navigationController: self.navigationController ?? UINavigationController())
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
}

extension EnableLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
