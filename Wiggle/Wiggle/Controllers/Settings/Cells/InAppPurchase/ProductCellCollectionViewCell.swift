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
        
        let array = product.localizedTitle.components(separatedBy: " ")
        
        productLabel.text = array[0]
        descriptionLabel.text = array[1]
        ProductCell.priceFormatter.locale = product.priceLocale
        priceLabel.text = "\(product.price) \(product.priceLocale.currencySymbol ?? "")"
        let monthlyPrice = Double(product.price) / 7.0
       
        layer.borderWidth = 1
        layer.cornerRadius = 12
        if isSelectedProduct {
            priceLabel.textColor = UIColor.goldenColor
            descriptionLabel.textColor = UIColor.goldenColor
            productLabel.textColor = UIColor.goldenColor
            layer.borderColor = UIColor.goldenColor.cgColor
            return
        }
        layer.borderColor = UIColor.white.cgColor
        priceLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.white
        productLabel.textColor = UIColor.white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

