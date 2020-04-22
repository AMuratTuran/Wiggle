//
//  DiscoverViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 4.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import Lottie
import PopupDialog
import PromiseKit
import CoreLocation

class DiscoverViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heartRateView: UIView!
    @IBOutlet weak var heartRateLabel: UILabel!
    
    var data: [User]?
    
    fileprivate var skipCount : Int = 0
    fileprivate var lastScrollOffsetY: CGFloat = 0.0
    fileprivate var lastScrollAmount: CGFloat = 0.0
    fileprivate var isLoading: Bool = false
    private var superLikeCount : Int = 0
    var heartRateResult : HeartRateKitResult?
    let locationManager = CLLocationManager()
    let animationView = AnimationView(name: "sensor_fingerprint")
    fileprivate var lastSelectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WiggleProducts.store.verifyReceipt { _, _ in}
        initializeViews()
        addObservers()
        checkLocationAuth()
        if !UserDefaults.standard.bool(forKey: "isOnboardingCompleted") {
            openOnboarding()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSuperlikeCount()
        addProductLogoToNavigationBar(selector: nil, logoName: "", isItalicTitle: true)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func getSuperlikeCount() {
        if let user = PFUser.current() {
            user.fetchInBackground(block: { (object, error) in
                if let error = error {
                    self.alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
                    return
                }
                guard let user = object as? PFUser else {
                    return
                }
                self.superLikeCount = user.object(forKey: "super_like") as! Int
            })
        }
    }
    
    func initializeViews() {
        locationManager.delegate = self
        
        setDefaultGradientBackground()
        navigationController?.navigationBar.tintColor = .white
        addMessageIconToNavigationBar()
        addSuperLikeIcon()
        transparentNavigationBar()
        transparentTabBar()
        hideBackBarButtonTitle()
        
        if let heartRateResult = heartRateResult {
            heartRateView.isHidden = false
            heartRateLabel.text = "\(Int(heartRateResult.bpm)) BPM"
        }else {
            heartRateView.isHidden = true
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: DiscoverCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: DiscoverCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        createLottieAnimation()
    }
    
    func openOnboarding() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let navigationViewController = storyboard.instantiateInitialViewController() as? UINavigationController
        navigationViewController?.modalPresentationStyle = .fullScreen
        if let nav = navigationViewController {
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeGender), name: Notification.Name("didChangeGender"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeDistance), name: Notification.Name("didChangeDistance"), object: nil)
    }
    
    func addSuperLikeIcon() {
        let superLikedYouButton = UIBarButtonItem(image: UIImage(named: "superlike-icon"), style: .plain, target: self, action: #selector(superLikedYouTapped))
        navigationItem.leftBarButtonItem = superLikedYouButton
    }
    
    @objc func didChangeGender() {
        self.skipCount = 0
        self.data = []
        if let heartRate = self.heartRateResult {
            getUsers(heartRate: Int(heartRate.bpm))
        }else {
            getUsers()
        }
    }
    
    @objc func didChangeDistance() {
        self.skipCount = 0
        self.data = []
        if let heartRate = self.heartRateResult {
            getUsers(heartRate: Int(heartRate.bpm))
        }else {
            getUsers()
        }
    }
    
    @objc func superLikedYouTapped() {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LikedYouViewController") as! LikedYouViewController
        viewController.showSuperLikedYou = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func checkLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            if let heartRate = self.heartRateResult {
                getUsers(heartRate: Int(heartRate.bpm))
            }else {
                getUsers()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            let requestAuthButton = DefaultButton(title: "Settings") {
                self.openSettings()
            }
            self.alertMessage(message: Localize.Error.NoLocationPermission, buttons: [DestructiveButton(title: Localize.Common.Close, action: nil),  requestAuthButton], isErrorMessage: true)
        }
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    
    func getUsers(heartRate: Int? = nil) {
        isLoading = true
        NetworkManager.getDiscoveryUsers(heartRate: heartRate, withSkip: skipCount, success: { (users) in
            self.isLoading = false
            if users.count == 0 {
                self.animationView.isHidden = false
                self.animationView.play()
                let doneButton = DefaultButton(title: Localize.Common.OKButton) {
                    
                }
                self.alertMessage(message: Localize.HomeScreen.noUserError, buttons: [doneButton], isErrorMessage: true, isGestureDismissal: false)
            }else{
                self.animationView.pause()
                self.animationView.isHidden = true
                self.skipCount += 50
            }
            var tempData: [User] = []
            users.forEach { user in
                let userModel = User(parseUser: user)
                tempData.append(userModel)
            }
            self.data = tempData
            DispatchQueue.main.async {
                delay(0.3) {
                    self.collectionView.reloadData()
                }
            }
        }) { error in
            self.isLoading = false
            self.alertMessage(message: error, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
        }
    }
    
    func loadMore() {
        NetworkManager.getDiscoveryUsers(withSkip: self.skipCount, success: { (users) in
            self.isLoading = false
            self.skipCount += 50
            users.forEach { user in
                let userModel = User(parseUser: user)
                self.data?.append(userModel)
            }
            self.collectionView.reloadData()
        }) { (error) in
            self.isLoading = false
            self.alertMessage(message: error, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
        }
    }
    
    func createLottieAnimation() {
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        animationView.center = self.view.center
        
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        view.addSubview(animationView)
        animationView.play()
    }
    
    func performAction(actionType: ActionType, indexPath: IndexPath) {
        if lastSelectedIndexPath.row < indexPath.row {
            disableVisibleCells()
        }
        
        self.lastSelectedIndexPath = indexPath
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        guard let receiver = self.data?[indexPath.row].objectId else {return}
        guard self.likeDislikeAction(action: actionType, receiver: receiver) else {return}
        
        switch actionType {
        case .dislike:
            _ = cell.playDislikeAnimation().done { _ in
                self.updateCollectionView(indexPath: indexPath)
            }
        case .like:
            _ = cell.playLikeAnimation().done { _ in
                self.updateCollectionView(indexPath: indexPath)
            }
        case .superlike:
            _ = cell.playSuperLikeAnimation().done { _ in
                self.updateCollectionView(indexPath: indexPath)
            }
        }
    }                                                                                                                                                                
    
    func updateCollectionView(indexPath: IndexPath) {
        self.data?.remove(at: indexPath.row)
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.enableVisibleCells()
        }
    }
    
    func dislikeAndRemove(indexPath: IndexPath) {
        performAction(actionType: .dislike, indexPath: indexPath)
    }
    
    func superLikeAction(indexPath: IndexPath) {
        performAction(actionType: .superlike, indexPath: indexPath)
    }
    
    func likeAction(indexPath: IndexPath) {
        performAction(actionType: .like, indexPath: indexPath)
    }
    
    func likeDislikeAction(action : ActionType, receiver : String) -> Bool{
        let cancelButton = DefaultButton(title: Localize.Common.CancelButton) {}
        let goToSuperLikeStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "SuperLikeInAppPurchaseViewController") as! SuperLikeInAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        let goToIAPStoreButton = DefaultButton(title: "WStore") {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }
        if action == .superlike && superLikeCount <= 0 {
            self.alertMessage(message: Localize.HomeScreen.superLikeError, buttons: [goToSuperLikeStoreButton, cancelButton], isErrorMessage: true)
            return false
        }else if action == .superlike {
            superLikeCount -= 1
        }
        NetworkManager.swipeActionWithDirection(receiver: receiver, action: action, success: {
        }) { (err) in
            if err.contains("1006") && action != .dislike{
                self.alertMessage(message: Localize.HomeScreen.likeError, buttons: [goToIAPStoreButton, cancelButton], isErrorMessage: true)
            }
        }
        return true
    }
    
    func disableVisibleCells() {
        self.collectionView.visibleCells.forEach {
            $0.isUserInteractionEnabled = false
        }
    }
    
    func enableVisibleCells() {
        self.collectionView.visibleCells.forEach {
            $0.isUserInteractionEnabled = true
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.data else { return 0 }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let data = self.data, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCell.reuseIdentifier, for: indexPath) as? DiscoverCell else { return UICollectionViewCell() }
        
        let profileImageHeroId = "profileImage\(indexPath.row)"
        let nameHeroId = "name\(indexPath.row)"
        let subLabelId = "subLabel\(indexPath.row)"
        cell.profileImageView.hero.id = profileImageHeroId
        cell.nameLabel.hero.id = nameHeroId
        cell.distanceLabel.hero.id = subLabelId
        
        cell.isUserInteractionEnabled = true
        cell.prepare(with: data[indexPath.row])
        cell.delegate = self
        cell.createBoostView()
        cell.indexPath = indexPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard self.data != nil else { return .zero }
        
        let availableWidth = collectionView.frame.width - 40
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: cellWidth + 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = data else { return }
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let dest = storyboard.instantiateViewController(withIdentifier: "ProfileDetailViewController") as? ProfileDetailViewController else { return }
        dest.userData = data[indexPath.row]
        dest.isHeroEnabled = true
        dest.indexOfParentCell = indexPath
        dest.discoverDelegate = self
        dest.modalPresentationStyle = .fullScreen
        self.present(dest, animated: true, completion: nil)
    }
}

extension DiscoverViewController: DiscoverCellDelegate {
    func likeTapped(at indexPath: IndexPath) {
        self.likeAction(indexPath: indexPath)
    }
    
    func superLikeTapped(at indexPath: IndexPath) {
        self.superLikeAction(indexPath: indexPath)
    }
    
    func dislikeTapped(at indexPath: IndexPath) {
        self.dislikeAndRemove(indexPath: indexPath)
    }
}

extension DiscoverViewController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastScrollAmount = 0.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard data != nil else { return }
        if lastScrollOffsetY < scrollView.contentOffset.y, !isLoading {
            let offset = scrollView.contentOffset.y
            let maxOffset = scrollView.contentSize.height - scrollView.bounds.size.height
            if (maxOffset - offset) <= 40 && scrollView.isDragging {
                isLoading = true
                loadMore()
            }
        }
        lastScrollOffsetY = scrollView.contentOffset.y
    }
}

extension DiscoverViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        let point = PFGeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        PFUser.current()?.setValue(point, forKey: "location")
        PFUser.current()?.saveInBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alertMessage(message: error.localizedDescription, buttons: [DefaultButton(title: Localize.Common.Close, action: nil)], isErrorMessage: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if let heartRate = self.heartRateResult {
                getUsers(heartRate: Int(heartRate.bpm))
            }else {
                getUsers()
            }
        default:
            return
        }
    }
}
