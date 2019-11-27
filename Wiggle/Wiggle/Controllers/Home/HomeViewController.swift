//
//  HomeViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var swipeableView: UIView!
    @IBOutlet weak var profileDetailView: UIView!
    @IBOutlet weak var routeProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.hero.modifiers = [.translate(y: -100), .useGlobalCoordinateSpace]
    }
    
    func configureViews() {
        swipeableView.cornerRadius(12.0)
        swipeableView.clipsToBounds = true
        imageView.image = UIImage(named: "profilePhoto")
        addTapGesture()
        imageView.heroID = "profileImageView"
        profileDetailView.heroID = "detailView"
    }
    
    func prepareView() {
        profileDetailView.addShadow(UIColor(named: "shadowColor")!)
        swipeableView.addShadow()
    }
    
    func addTapGesture() {
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(moveToDetail))
        self.view.isUserInteractionEnabled = true
        profileDetailView.isUserInteractionEnabled = true
        swipeableView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func moveToDetail(gestureRecognizer: UIGestureRecognizer) {
        print("tapped")
        moveToProfileDetailViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
    }
    
    override func viewWillLayoutSubviews() {
        prepareView()
    }
    
    @IBAction func routeProfileAction(_ sender: UIButton) {
        //moveToProfileViewController()
        moveToProfileDetailViewController()
    }
    
}

