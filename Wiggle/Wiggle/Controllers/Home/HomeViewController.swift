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
    @IBOutlet weak var routeProfileButton: UIButton!
    @IBOutlet weak var kolodaView: KolodaView!
    
    var cardArray = [WiggleCardModel]()
    
    var currentCard = WiggleCard()
//    let cardView = WiggleCard.init(frame: CGRect.zero)
    let heartbeatView = Heartbeat.init(frame: CGRect.zero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
        fetchUsers()
    }
    
    override func viewWillLayoutSubviews() {
        prepareView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.view.hero.modifiers = [.translate(y: -100), .useGlobalCoordinateSpace]
    }
    
    func configureViews() {
        kolodaView.cornerRadius(12.0)
        kolodaView.clipsToBounds = true
        addTapGesture()
    }
    
    func prepareView() {
        kolodaView.addShadow()
    }
    
    func addTapGesture() {
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(moveToDetail))
        self.view.isUserInteractionEnabled = true
        kolodaView.isUserInteractionEnabled = true
        kolodaView.addGestureRecognizer(tapGesture)
    }
    
    @objc func moveToDetail(gestureRecognizer: UIGestureRecognizer) {
        print("tapped")
        moveToProfileDetailViewController()
    }
    
    @IBAction func routeProfileAction(_ sender: UIButton) {
        moveToProfileDetailViewController()
    }
    
    func fetchUsers(){
        NetworkManager.getUsersForSwipe(success: { (users) in
            self.cardArray.append(contentsOf: users)
            self.kolodaView.reloadData()
        }) { fail in
            print("===========\(fail)===========")
        }
    }
    
}
extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
}
extension HomeViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return cardArray.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.moderate
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let cardView = WiggleCard.init(frame: CGRect.zero)
        
        if cardArray.count == 0{
            return heartbeatView
        }
        cardView.model = cardArray[index]
        cardView.updateUI()
        currentCard = cardView
        return cardView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
    }
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        moveToProfileDetailViewController()
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.up, .left, .right]
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        switch direction {
        case .left:
            UIView.animate(withDuration: 0.0) {
                self.currentCard.view.likeImage.alpha = finishPercentage/100
            }
        case .right:
            self.currentCard.view.dislikeImage.alpha = finishPercentage/100
        default:
            print("nereye gidiyo")
        }
    }
    
    func kolodaDidResetCard(_ koloda: KolodaView) {
        self.currentCard.view.likeImage.alpha = 0.0
        self.currentCard.view.dislikeImage.alpha = 0.0
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        switch direction {
        case .right:
            print("Saga Atti")
        case .left:
            print("Sola Atti")
        case .up:
            print("Yukari Atti")
        default:
            print("Atamadi")
        }
        cardArray.remove(at: index)
        self.currentCard.view.likeImage.alpha = 0.0
        self.currentCard.view.dislikeImage.alpha = 0.0
    }
}
