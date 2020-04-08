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
    
    var data: [User]?
    fileprivate var skipCount : Int = 0
    fileprivate var lastScrollOffsetY: CGFloat = 0.0
    fileprivate var lastScrollAmount: CGFloat = 0.0
    fileprivate var isLoading: Bool = false
    private var superLikeCount : Int = 0
    
    let locationManager = CLLocationManager()
    
    let animationView = AnimationView(name: "sensor_fingerprint")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
        
        superLikeCount = PFUser.current()?.getSuperLike() ?? 0
        
        checkLocationAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func initializeViews() {
        locationManager.delegate = self

        setDefaultGradientBackground()
        navigationController?.navigationBar.tintColor = .white
        addMessageIconToNavigationBar()
        addProductLogoToNavigationBar(selector: nil, logoName: "", isItalicTitle: true)
        transparentNavigationBar()
        transparentTabBar()
        hideBackBarButtonTitle()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: DiscoverCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: DiscoverCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        createLottieAnimation()
    }
    
    func checkLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            getUsers()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        default:
            let requestAuthButton = DefaultButton(title: "Settings") {
                self.openSettings()
            }
            self.alertMessage(message: "Lokasyon izni yok", buttons: [DestructiveButton(title: Localize.Common.Close, action: nil),  requestAuthButton], isErrorMessage: true)
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
    
    func getUsers() {
        isLoading = true
        NetworkManager.getDiscoveryUsers(withSkip: skipCount, success: { (users) in
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
    
    func dislikeAndRemove(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        guard let receiver = self.data?[indexPath.row].objectId else {return}
        guard self.swipeAction(action: .dislike, receiver: receiver) else {return}
        
        _ = cell.playDislikeAnimation().done { _ in
            self.data?.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func superLikeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        guard let receiver = self.data?[indexPath.row].objectId else {return}
        guard self.swipeAction(action: .superlike, receiver: receiver) else {return}
        
        data?[indexPath.row].isLiked = true
        _ = cell.playSuperLikeAnimation().done { _ in
            self.data?.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func likeAction(indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DiscoverCell else { return }
        guard let receiver = self.data?[indexPath.row].objectId else {return}
        guard self.swipeAction(action: .like, receiver: receiver) else {return}
        
        data?[indexPath.row].isLiked = true
        _ = cell.playLikeAnimation().done { _ in
            self.data?.remove(at: indexPath.row)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (finished) in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
    }
    
    func swipeAction(action : ActionType, receiver : String) -> Bool{
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
        if action == .superlike && superLikeCount <= 0{
            self.alertMessage(message: Localize.HomeScreen.superLikeError, buttons: [goToSuperLikeStoreButton, cancelButton], isErrorMessage: true)
            return false
        }else if action == .superlike{
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
        
        cell.prepare(with: data[indexPath.row])
        cell.delegate = self
        cell.createBoostView()
        cell.showBoostView()
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
            self.getUsers()
        default:
            return
        }
    }
}
