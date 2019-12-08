//
//  HomeViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import Koloda

class HomeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var profileDetailView: UIView!
    @IBOutlet weak var routeProfileButton: UIButton!
    @IBOutlet weak var kolodaView: KolodaView!
    
    var cards = [WiggleUser]()
    
    func generateMockData(){
        let user1 = WiggleUser()
        user1.firstName = "Tolga"
        user1.lastName = "Tas"
        user1.bio = "iOS Developer"
        user1.birthDay = Date()
        
        let user2 = WiggleUser()
        user2.firstName = "Murat"
        user2.lastName = "Turan"
        user2.bio = "iOS Developer"
        user2.birthDay = Date()
        cards.append(contentsOf: [user1, user2])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateMockData()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.view.hero.modifiers = [.translate(y: -100), .useGlobalCoordinateSpace]
    }
    
    func configureViews() {
        kolodaView.cornerRadius(12.0)
        kolodaView.clipsToBounds = true
        imageView.image = UIImage(named: "profilePhoto")
        addTapGesture()
        imageView.heroID = "profileImageView"
        profileDetailView.heroID = "detailView"
    }
    
    func prepareView() {
        profileDetailView.addShadow(UIColor(named: "shadowColor")!)
        kolodaView.addShadow()
    }
    
    func addTapGesture() {
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(moveToDetail))
        self.view.isUserInteractionEnabled = true
        profileDetailView.isUserInteractionEnabled = true
        kolodaView.isUserInteractionEnabled = true
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
extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
}
extension HomeViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return cards.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.moderate
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIImageView(image: UIImage(named: "profilePhoto"))
//        return kolodaView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
    }
}
