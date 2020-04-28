//
//  SuperLikeInAppPurchaseViewController.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 10.02.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import StoreKit
import PopupDialog

class SuperLikeInAppPurchaseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    var superlikeProducts: [SKProduct] = []
    var boostProducts: [SKProduct] = []
    var boostAndSuperlikeProducts: [SKProduct] = []
    var purchasedProduct : String = ""
    var selectedProduct : SKProduct?{
        didSet{
            collectionView.reloadData()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var freeStoryLabel: UILabel!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var secondaryLabel: UILabel!
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setGradientBackground()
        continueButton.bringSubviewToFront(continueButton.titleLabel!)
        
        configureViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SuperLikeInAppPurchaseViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        requestProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setGradientBackground()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Class Functions
    func requestProducts(){
        WiggleProducts.boostAndSuperlikeProducts.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    let productsSorted = products?.sorted { Int($0.price) < Int($1.price) }
                    self.boostAndSuperlikeProducts = productsSorted ?? []
                    WiggleProducts.boostProducts.requestProducts{ [weak self] success, products in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if success {
                                let productsSorted = products?.sorted { Int($0.price) < Int($1.price) }
                                self.boostProducts = productsSorted ?? []
                                WiggleProducts.superlikeProducts.requestProducts{ [weak self] success, products in
                                    guard let self = self else { return }
                                    DispatchQueue.main.async {
                                        if success {
                                            let productsSorted = products?.sorted { Int($0.price) < Int($1.price) }
                                            self.superlikeProducts = productsSorted ?? []
                                            if productsSorted?.first?.localizedDescription.isEmpty ?? true{
                                                let cancelButton = DefaultButton(title: Localize.Common.OKButton) {self.dismiss(animated: true) {}}
                                                self.alertMessage(message: Localize.Purchase.PremiumError, buttons: [cancelButton], isErrorMessage: true)
                                            }else{
                                                self.collectionView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func configureViews(){
        freeStoryLabel.textColor = UIColor.white
        freeStoryLabel.text = Localize.Purchase.RiseWithSuperlike
        
        secondaryLabel.textColor = UIColor.white
        secondaryLabel.text = Localize.Purchase.Get4XLucky
        
        continueButton.layer.cornerRadius = continueButton.frame.height / 2
        continueButton.setTitle(Localize.Purchase.PurchaseButton, for: .normal)
        continueButton.backgroundColor = UIColor.goldenColor
        continueButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productId = notification.object as? String else {return}
        
        if let index = superlikeProducts.firstIndex(where: { (product) -> Bool in
            product.productIdentifier == productId
        }){
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }else if let index = boostProducts.firstIndex(where: { (product) -> Bool in
            product.productIdentifier == productId
        }){
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }else if let index = boostAndSuperlikeProducts.firstIndex(where: { (product) -> Bool in
            product.productIdentifier == productId
        }){
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    // MARK: - IAP Functions
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true) {}
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
        return superlikeProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return superlikeProducts.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var product = SKProduct()
        switch indexPath.section {
        case 0:
            product = superlikeProducts[(indexPath as NSIndexPath).row]
        case 1:
            product = boostProducts[(indexPath as NSIndexPath).row]
        case 2:
            product = boostAndSuperlikeProducts[(indexPath as NSIndexPath).row]
        default:
            product = superlikeProducts[(indexPath as NSIndexPath).row]
        }
        
        selectedProduct = product
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductCell
        var product = SKProduct()
        switch indexPath.section {
        case 0:
            product = superlikeProducts[(indexPath as NSIndexPath).row]
        case 1:
            product = boostProducts[(indexPath as NSIndexPath).row]
        case 2:
            product = boostAndSuperlikeProducts[(indexPath as NSIndexPath).row]
        default:
            product = superlikeProducts[(indexPath as NSIndexPath).row]
        }
        
        cell.product = product
        selectedProduct == product ? (cell.isSelectedProduct = true) : (cell.isSelectedProduct = false)
        cell.setUI()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = self.view.frame.width
        let spacing = 10
        let totalSpace: CGFloat = CGFloat(20 + ((superlikeProducts.count - 1) * spacing))
        let available = screenSize - totalSpace
        let cellWidth = (available / CGFloat(superlikeProducts.count))
        return CGSize(width: cellWidth, height: 100)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
}
