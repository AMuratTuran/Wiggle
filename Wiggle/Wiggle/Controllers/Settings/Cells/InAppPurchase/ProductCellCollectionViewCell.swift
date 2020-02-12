//
//  ProductCellCollectionViewCell.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 10.02.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import StoreKit

class ProductCell: UICollectionViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    var product: SKProduct?
    var isSelectedProduct: Bool = false
    
    func setUI(){
        guard let product = product else { return }
        
        priceLabel.bringSubviewToFront(self)
        descriptionLabel.bringSubviewToFront(self)
        priceLabel.bringSubviewToFront(self)
        
        var array = product.localizedTitle.components(separatedBy: " ")
        
        productLabel.text = array[0]
        descriptionLabel.text = array[1]
        ProductCell.priceFormatter.locale = product.priceLocale
        priceLabel.text = "\(product.price) \(product.priceLocale.currencySymbol ?? "")"
        let monthlyPrice = Double(product.price) / 7.0
       
        layer.borderWidth = 1
        layer.cornerRadius = 12
        if isSelectedProduct {
            backgroundImage.image = UIImage(named: "productCellBackground")
            priceLabel.textColor = UIColor.white
            descriptionLabel.textColor = UIColor.white
            productLabel.textColor = UIColor.white
            return
        }
        backgroundImage.image = nil
        priceLabel.textColor = UIColor(red: 238/255, green: 74/255, blue: 131/255, alpha: 1.0)
        descriptionLabel.textColor = UIColor(red: 238/255, green: 74/255, blue: 131/255, alpha: 1.0)
        productLabel.textColor = UIColor(red: 238/255, green: 74/255, blue: 131/255, alpha: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

