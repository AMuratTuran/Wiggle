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

protocol userActionsDelegate {
    func likeAction(receiverObjectId : String, direction : SwipeResultDirection)
    func dislikeAction(receiverObjectId : String, direction : SwipeResultDirection)
    func superlikeAction(receiverObjectId : String, direction : SwipeResultDirection)
}

class HomeViewController: UIViewController, userActionsDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    // MARK: Variables
    var cardArray = [WiggleCardModel]()
    var currentCardModel : WiggleCardModel?
    
    var skipCount : Int = 0
    
    let locationManager = CLLocationManager()
    let animationView = AnimationView(name: "sensor_fingerprint")
    var fetchUsersGestureRecognizer = UITapGestureRecognizer()
    var isLaunchedFromPN:Bool = false
    
    var superLikeCount : Int = 0
    
    // MARK: Override Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createLottieAnimation()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WiggleProducts.store.verifyReceipt { _, _ in
        }
        addProductLogoToNavigationBar(selector: nil, logoName: "", isItalicTitle: true)
        configureViews()
        updateObjectId()
        hideBackBarButtonTitle()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.view.hero.modifiers = [.translate(y: -100), .useGlobalCoordinateSpace]
        
        setupLocationManager()
        
        superLikeCount = PFUser.current()?.getSuperLike() ?? 0
        
        if isLaunchedFromPN {
            let transition = CATransition()
            transition.duration = 0.2
            transition.type = CATransitionType.fade
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let chatListVC = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.pushViewController(chatListVC, animated: true)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didChangeGender), name: Notification.Name("didChangeGender"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeDistance), name: Notification.Name("didChangeDistance"), object: nil)
    }
    
    @objc func didChangeGender() {
        self.skipCount = 0
        fetchUsers()
    }
    
    @objc func didChangeDistance() {
        self.skipCount = 0
        fetchUsers()
    }
    
    // MARK: Class Functions
    func createLottieAnimation() {
        animationView.isUserInteractionEnabled = true
        fetchUsersGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fetchUsers))
        animationView.addGestureRecognizer(fetchUsersGestureRecognizer)
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
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
        transparentNavigationBar()
        transparentTabBar()
        self.view.setGradientBackground()
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
        //        moveToProfileDetailViewController(data : data)
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
                let doneButton = DefaultButton(title: Localize.Common.OKButton) {
                    
                }
                self.alertMessage(message: Localize.HomeScreen.noUserError, buttons: [doneButton], isErrorMessage: true, isGestureDismissal: false)
            }else{
                self.animationView.pause()
                self.animationView.isHidden = true
                self.buttonsStackView.isHidden = false
                self.skipCount += 5
            }
            self.cardArray.append(contentsOf: users)
            self.kolodaView.reloadData()
        }) { fail in
            print("===========\(fail)===========")
        }
    }
    
    func swipeAction(direction : SwipeResultDirection, fromButton : Bool){
        let cancelButton = DefaultButton(title: Localize.Common.CancelButton) {}
        let goToStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        guard let receiverObjectId = currentCardModel?.objectId else {return}
        if fromButton{
            kolodaView.swipe(direction)
        }
        if direction == .up && superLikeCount <= 0{
            self.alertMessage(message: Localize.HomeScreen.superLikeError, buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
            kolodaView.revertAction()
        }else if direction == .up{
            superLikeCount -= 1
        }
        NetworkManager.swipeActionWithDirection(receiver: receiverObjectId, direction: direction, success: {
        }) { (err) in
            if err.contains("1006") && direction != .left{
                self.alertMessage(message: Localize.HomeScreen.likeError, buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
                self.kolodaView.revertAction()
            }
        }
    }
    
    // MARK: Protocol Actions
    
    func likeAction(receiverObjectId: String, direction: SwipeResultDirection) {
        swipeAction(direction: direction, fromButton: true)
    }
    
    func dislikeAction(receiverObjectId: String, direction: SwipeResultDirection) {
        swipeAction(direction: direction, fromButton: true)
    }
    
    func superlikeAction(receiverObjectId: String, direction: SwipeResultDirection) {
        swipeAction(direction: direction, fromButton: true)
    }
    func revertAction(){
        let cancelButton = DefaultButton(title: Localize.Common.CancelButton) {}
        let goToStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        guard let user = PFUser.current() else {
            self.alertMessage(message: Localize.HomeScreen.revertError, buttons: [goToStoreButton, cancelButton], isErrorMessage: true)
            return}
        if user.getGold(){
            kolodaView.revertAction()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func routeProfileAction(_ sender: UIButton) {
        guard let data = currentCardModel else {return}
        //        moveToProfileDetailViewController(data : data)
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.right, fromButton: true)
    }
    @IBAction func dislikeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.left, fromButton: true)
    }
    @IBAction func superLikeButtonAction(_ sender: Any) {
        swipeAction(direction: SwipeResultDirection.up, fromButton: true)
    }
    
    @IBAction func revertButtonAtion(_ sender: Any) {
        revertAction()
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
        moveToProfileDetailViewController(data : data, delegate : self)
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.up, .left, .right]
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        if let currentCard = koloda.subviews.last?.subviews[0] as? WiggleCard{
            switch direction {
            case .right:
                UIView.animate(withDuration: 0.0) {
                    currentCard.view.likeImage.alpha = finishPercentage/50
                }
            case .left:
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
                if error.debugDescription.contains("209"){
                    PFUser.logOutInBackground { _ in
                        self.startAnimating(self.view, startAnimate: false)
                        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.SessionToken)
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        delegate.initializeWindow()
                    }
                }else{
                    self.displayError(message: error?.localizedDescription ?? "")
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
