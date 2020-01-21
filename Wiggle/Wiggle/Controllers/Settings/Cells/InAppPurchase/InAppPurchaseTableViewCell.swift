//
//  InAppPurchaseTableViewCell.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 21.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import StoreKit

class InAppPurchaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    var product : SKProduct?{
        didSet{
            setUI()
        }
    }
    
    var testModel : productTestModel?{
        didSet{
            setUI()
        }
    }
    
    func setUI(){
        guard let product = testModel else {return}
        durationLabel.text = product.duration
        priceLabel.text = product.price
        
    }

}

class productTestModel{
    var duration : String?
    var discountRate : String?
    var price : String?
    
    init(duration : String, discountRate : String, price : String){
        self.duration = duration
        self.discountRate = discountRate
        self.price = price
    }
}
