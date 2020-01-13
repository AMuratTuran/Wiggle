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
    // MARK: Outlets
    @IBOutlet weak var kolodaView: KolodaView!
    
    // MARK: Variables
    var cardArray = [WiggleCardModel]()
    var currentCard : WiggleCard?
    var currentCardModel : WiggleCardModel?
    
    // MARK: Override Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
    }
    
    override func viewWillLayoutSubviews() {
        prepareView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateObjectId()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.view.hero.modifiers = [.translate(y: -100), .useGlobalCoordinateSpace]
        fetchUsers()
    }
    
    // MARK: Class Functions
    func updateObjectId(){
        if let currentUser = PFUser.current(){
            if let id = currentUser.objectId{
                AppConstants.objectId = id
            }
        }
    }
    
    func configureViews() {
        kolodaView.cornerRadius(12.0)
        kolodaView.clipsToBounds = true
        addTapGesture()
    }
    
    func prepareView() {
        kolodaView.addShadow()
        addMessageIconToNavigationBar()
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
    
    func fetchUsers(){
        NetworkManager.getUsersForSwipe(success: { (users) in
            self.cardArray.append(contentsOf: users)
            self.kolodaView.reloadData()
        }) { fail in
            print("===========\(fail)===========")
        }
    }
    
    func swipeAction(direction : SwipeResultDirection){
        guard let receiverObjectId = currentCardModel?.objectId else {return}
        NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: direction)
    }
    
    // MARK: IBActions
    
    @IBAction func routeProfileAction(_ sender: UIButton) {
        moveToProfileDetailViewController()
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.left)
    }
    @IBAction func dislikeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.right)
    }
    @IBAction func superLikeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.up)
    }
}

// MARK: KolodaViewDelegate Functions

extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
}

// MARK: KolodaViewDataSource Functions
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
            return Heartbeat.init(frame: CGRect.zero)
        }
        cardView.model = cardArray[index]
        cardView.updateUI()
        cardView.view.likeImage.alpha = 0.0
        cardView.view.dislikeImage.alpha = 0.0
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
        if let currentCard = koloda.subviews.last?.subviews[0] as? WiggleCard{
            switch direction {
            case .left:
                currentCard.view.likeImage.alpha = finishPercentage/50
            case .right:
                UIView.animate(withDuration: 0.0) {
                    currentCard.view.dislikeImage.alpha = finishPercentage/50
                }
            default:
                print("nereye gidiyo")
            }
        }
    }
    
    func kolodaDidResetCard(_ koloda: KolodaView) {
        if let currentCard = koloda.subviews.last?.subviews[0] as? WiggleCard{
            currentCard.view.likeImage.alpha = 0.0
            currentCard.view.dislikeImage.alpha = 0.0
        }
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        swipeAction(direction: direction)
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        currentCardModel = cardArray[index]
    }
}
