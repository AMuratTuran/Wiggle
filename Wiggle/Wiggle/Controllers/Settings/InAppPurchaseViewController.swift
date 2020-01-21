//
//  InAppPurchaseViewController.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 20.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

class InAppPurchaseViewController: UIViewController {
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureViews()
    }
    
    func configureViews(){
        seperatorView.layer.cornerRadius = seperatorView.bounds.height / 2
        purchaseButton.layer.cornerRadius = purchaseButton.bounds.height / 10
    }

}
extension InAppPurchaseViewController: UITableViewDelegate{
    
}
extension InAppPurchaseViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InAppPurchaseTableViewCell", for: indexPath) as! InAppPurchaseTableViewCell
        let product = productTestModel(duration: "1 Ay", discountRate: "", price: "31 tl")
        cell.testModel = product
        return cell
    }
    
    
}
