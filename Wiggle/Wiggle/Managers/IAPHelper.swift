//
//  IAPHelper.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 26.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import StoreKit
import SwiftyStoreKit
import Parse

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}

open class IAPHelper: NSObject  {
    
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "20511a59762f45b8a5bc39f60f29abb7")
    func verifyReceipt(completion : @escaping (Bool, String) -> Void){
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productIds = Set<String>(["wiggle1Month", "wiggle3Months", "wiggle6Months", "wiggle12Months"])
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(
                    ofType: .autoRenewable,
                    productIds: productIds,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    isPremium = true
                    print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
                    PFUser.current()?.setValue(true, forKey: "isGold")
                    PFUser.current()?.saveInBackground()
                    completion(true, items[0].productId)
                case .expired, .notPurchased:
                    isPremium = false
                    completion(false, "")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(false, "")
            }
        }
    }
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        
        SKPaymentQueue.default().add(self)
        
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
    }
}

// MARK: - StoreKit API

extension IAPHelper {
    
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
}

public struct WiggleProducts {
    
    public static let oneMonthSubs = "wiggle1Month"
    public static let threeMonthsSubs = "wiggle3Months"
    public static let sixMonthsSubs = "wiggle6Months"
    public static let twelveMonthsSubs = "wiggle12Months"
    public static let oneSuperLike = "wiggle1SuperLike"
    public static let fiveSuperLikes = "wiggle5SuperLikes"
    public static let twentyFiveSuperLikes = "wiggle25SuperLikes"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [WiggleProducts.oneMonthSubs, WiggleProducts.threeMonthsSubs, WiggleProducts.sixMonthsSubs, WiggleProducts.twelveMonthsSubs]
    
    private static let superLikeProductIdentifiers: Set<ProductIdentifier> = [WiggleProducts.oneSuperLike, WiggleProducts.fiveSuperLikes, WiggleProducts.twentyFiveSuperLikes]
    
    public static let store = IAPHelper(productIds: WiggleProducts.productIdentifiers)
    public static let superLikeStore = IAPHelper(productIds: WiggleProducts.superLikeProductIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
