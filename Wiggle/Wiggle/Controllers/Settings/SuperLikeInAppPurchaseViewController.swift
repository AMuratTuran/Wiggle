//
//  SuperLikeInAppPurchaseViewController.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 10.02.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import StoreKit

class SuperLikeInAppPurchaseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    var products: [SKProduct] = []
    var purchasedProduct : String = ""
    var selectedProduct : SKProduct?{
        didSet{
            collectionView.reloadData()
        }
    }
    var selectedProductPrice = ""{
        didSet{
            updateBottomLabel()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var freeStoryLabel: UILabel!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.bringSubviewToFront(continueButton.titleLabel!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SuperLikeInAppPurchaseViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        
        WiggleProducts.superLikeStore.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.products = products ?? []
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Class Functions
    func updateBottomLabel(){
        bottomLabel.text = "About subscriptions: You are beginning a paid auto renewing subscription. Subscription automatically renews for per month. Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase."
    }
    
    // MARK: - IAP Functions
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.firstIndex(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    // MARK: - Button Actions
    
    @IBAction func continueButtonAction(_ sender: Any) {
        guard let product = selectedProduct else {return}
        WiggleProducts.superLikeStore.buyProduct(product)
    }
    
    @IBAction func restoreButtonAction(_ sender: Any) {
        WiggleProducts.superLikeStore.restorePurchases()
    }
    @IBAction func termOfUseAction(_ sender: Any) {
        if let url = URL(string: "bs.easypeekapp.com/termsofuse.php") {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func privacyPolicyAction(_ sender: Any) {
        if let url = URL(string: "bs.easypeekapp.com/privacy.php") {
            UIApplication.shared.open(url)
        }
    }
}


// MARK: - CollectionView Functions

extension SuperLikeInAppPurchaseViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProduct = products[(indexPath as NSIndexPath).row]
        selectedProductPrice = selectedProduct?.localizedPrice ?? "0"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductCell
        
        let product = products[(indexPath as NSIndexPath).row]
        
        cell.product = product
        selectedProduct == product ? (cell.isSelectedProduct = true) : (cell.isSelectedProduct = false)
        cell.setUI()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = self.view.frame.width
        let spacing = 10
        let totalSpace: CGFloat = CGFloat(20 + ((products.count - 1) * spacing))
        let available = screenSize - totalSpace
        let cellWidth = (available / CGFloat(products.count))
        return CGSize(width: cellWidth, height: 100)
    }
}
