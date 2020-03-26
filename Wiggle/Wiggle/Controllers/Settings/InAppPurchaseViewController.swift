//
//  InAppPurchaseViewController.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 20.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import StoreKit
import PopupDialog

class InAppPurchaseViewController: UIViewController {
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var beGoldMemberLabel: UILabel!
    @IBOutlet weak var unlimitedLikeLabel: UILabel!
    @IBOutlet weak var whoLikedYouLabel: UILabel!
    
    
    var products: [SKProduct] = []
    
    var selectedProduct : SKProduct?
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setGradientBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        reload()
        configureViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(InAppPurchaseViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
    }
    
    func configureViews(){
        topLabel.textColor = UIColor.goldenColor
        
        closeButton.setTitle(Localize.Common.Close, for: .normal)
        
        purchaseButton.layer.cornerRadius = purchaseButton.frame.height / 2
        purchaseButton.setTitle(Localize.Purchase.PurchaseButton, for: .normal)
        purchaseButton.backgroundColor = UIColor.goldenColor
        purchaseButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        
        seperatorView.layer.cornerRadius = seperatorView.bounds.height / 2
        seperatorView.backgroundColor = UIColor.goldenColor
        
        beGoldMemberLabel.text = Localize.Purchase.BeGold
        beGoldMemberLabel.textColor = UIColor.white
        
        unlimitedLikeLabel.text = Localize.Purchase.UnlimitedLike
        unlimitedLikeLabel.textColor = UIColor.white
        
        whoLikedYouLabel.text = Localize.Purchase.WhoLikedYou
        whoLikedYouLabel.textColor = UIColor.white
        
    }
    
    @objc func reload() {
        self.startAnimating(self.view, startAnimate: true)
        WiggleProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    let productsSorted = products?.sorted { Int($0.price) < Int($1.price) }
                    self.products = productsSorted ?? []
                    if productsSorted?.first?.localizedDescription.isEmpty ?? true{
                        let cancelButton = DefaultButton(title: Localize.Common.OKButton) {self.dismiss(animated: true) {}}
                        self.alertMessage(message: Localize.Purchase.PremiumError, buttons: [cancelButton], isErrorMessage: true)
                    }else{
                        DispatchQueue.main.async {
                            self.startAnimating(self.view, startAnimate: false)
                            self.tableView.reloadData()
                        }
                    }
                }else {
                    self.startAnimating(self.view, startAnimate: false)
                    self.displayError(message: "Something went wrong")
                }
            }
        }
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.firstIndex(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    @IBAction func buyButtonAction(_ sender: Any) {
        guard let selectedProduct = selectedProduct else {return}
        WiggleProducts.store.buyProduct(selectedProduct)
    }
    
    
}
extension InAppPurchaseViewController: UITableViewDelegate{
    
}
extension InAppPurchaseViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InAppPurchaseTableViewCell", for: indexPath) as! InAppPurchaseTableViewCell
        let product = products[(indexPath as NSIndexPath).row]
        
        cell.product = product
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[(indexPath as NSIndexPath).row]
        selectedProduct = product
    }
    
    
}
