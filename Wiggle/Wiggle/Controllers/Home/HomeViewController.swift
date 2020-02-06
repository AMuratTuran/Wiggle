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
import CoreLocation
import Lottie
import PopupDialog

class HomeViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    // MARK: Variables
    var cardArray = [WiggleCardModel]()
    var currentCardModel : WiggleCardModel?
    
    var skipCount : Int = 0
    
    let locationManager = CLLocationManager()
    let animationView = AnimationView(name: "heartbeat")
    var fetchUsersGestureRecognizer = UITapGestureRecognizer()
    
    var superLikeCount : Int = 0
    
    // MARK: Override Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createLottieAnimation()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func testModel(){
        let user1 = WiggleCardModel(profilePicture: "", nameSurname: "Tolga Tas", location: "", distance: "", bio: "", objectId: "")
        let user2 = WiggleCardModel(profilePicture: "", nameSurname: "Tolga Tas", location: "", distance: "", bio: "", objectId: "")
        let user3 = WiggleCardModel(profilePicture: "", nameSurname: "Tolga Tas", location: "", distance: "", bio: "", objectId: "")
        let user4 = WiggleCardModel(profilePicture: "", nameSurname: "Tolga Tas", location: "", distance: "", bio: "", objectId: "")
        let user5 = WiggleCardModel(profilePicture: "", nameSurname: "Tolga Tas", location: "", distance: "", bio: "", objectId: "")
        
        cardArray = [user1, user2, user3, user4, user5]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WiggleProducts.store.verifyReceipt { _, _ in
        }
        addProductLogoToNavigationBar()
        configureViews()
        updateObjectId()
        hideBackBarButtonTitle()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.view.hero.modifiers = [.translate(y: -100), .useGlobalCoordinateSpace]
        
        setupLocationManager()
        
        superLikeCount = PFUser.current()?.getSuperLike() ?? 0
    }
    
    // MARK: Class Functions
    func createLottieAnimation() {
        animationView.isUserInteractionEnabled = true
        fetchUsersGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fetchUsers))
        animationView.addGestureRecognizer(fetchUsersGestureRecognizer)
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        view.addSubview(animationView)
        animationView.play()
    }
    
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
        animationView.isHidden = false
        animationView.play()
        buttonsStackView.isHidden = true
        addMessageIconToNavigationBar()
        kolodaView.reloadData()
        kolodaView.addShadow()
    }
    
    func addTapGesture() {
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(moveToDetail))
        self.view.isUserInteractionEnabled = true
        kolodaView.isUserInteractionEnabled = true
        kolodaView.addGestureRecognizer(tapGesture)
    }
    
    @objc func moveToDetail(gestureRecognizer: UIGestureRecognizer) {
        guard let data = currentCardModel else {return}
        moveToProfileDetailViewController(data : data)
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
    }
    
    @objc func fetchUsers(){
        NetworkManager.getUsersForSwipe(withSkip: skipCount, success: { (users) in
            if users.count == 0{
                self.animationView.isHidden = false
                self.animationView.play()
                self.buttonsStackView.isHidden = true
            }else{
                self.animationView.pause()
                self.animationView.isHidden = true
                self.buttonsStackView.isHidden = false
            }
            self.cardArray.append(contentsOf: users)
            self.kolodaView.reloadData()
            self.skipCount += 5
        }) { fail in
            print("===========\(fail)===========")
        }
    }
    
    func swipeAction(direction : SwipeResultDirection, fromButton : Bool){
        guard let receiverObjectId = currentCardModel?.objectId else {return}
        if fromButton{
            kolodaView.swipe(direction)
        }
        if direction == .up && superLikeCount <= 0{
            let cancelButton = DefaultButton(title: "İptal") {}
            let goToStoreButton = DefaultButton(title: "WStore") {
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
                self.navigationController?.present(destionationViewController, animated: true, completion: {})
            }
            self.alertMessage(message: "Super Likeların bitti almak için store'a git", buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
        }else{
            NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: direction)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func routeProfileAction(_ sender: UIButton) {
        guard let data = currentCardModel else {return}
        moveToProfileDetailViewController(data : data)
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.left, fromButton: true)
    }
    @IBAction func dislikeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.right, fromButton: true)
    }
    @IBAction func superLikeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.up, fromButton: true)
    }
}

// MARK: KolodaViewDelegate Functions

extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        self.animationView.isHidden = false
        animationView.play()
        self.buttonsStackView.isHidden = true
        fetchUsers()
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
        guard let data = currentCardModel else {return}
        moveToProfileDetailViewController(data : data)
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.up, .left, .right]
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        if let currentCard = koloda.subviews.last?.subviews[0] as? WiggleCard{
            switch direction {
            case .left:
                UIView.animate(withDuration: 0.0) {
                    currentCard.view.likeImage.alpha = finishPercentage/50
                }
            case .right:
                UIView.animate(withDuration: 0.0) {
                    currentCard.view.dislikeImage.alpha = finishPercentage/50
                }
            default:
                UIView.animate(withDuration: 0.0) {
//                    currentCard.view.superLikeImage.alpha = finishPercentage/50
                }
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
        swipeAction(direction: direction, fromButton: false)
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        currentCardModel = cardArray[index]
    }
}
// MARK: CLLocationManagerDelegate Functions
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        PFUser.current()?.setValue(point, forKey: "location")
        AppConstants.location = point
        fetchUsers()
        PFUser.current()?.saveInBackground(block: { (result, error) in
            if error != nil {
                self.displayError(message: error?.localizedDescription ?? "")
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
