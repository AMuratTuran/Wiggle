//
//  InAppPurchaseViewController.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 20.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import StoreKit

class InAppPurchaseViewController: UIViewController {
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var products: [SKProduct] = []
    
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
        seperatorView.layer.cornerRadius = seperatorView.bounds.height / 2
        purchaseButton.layer.cornerRadius = purchaseButton.bounds.height / 10
    }
    
    @objc func reload() {
        WiggleProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products ?? []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
        WiggleProducts.store.buyProduct(product)
    }
    
    
}
