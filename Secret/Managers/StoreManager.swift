//
//  StoreManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/04/07.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import StoreKit

extension SKProduct {
    func priceString() -> String {
        
        let formatter = NumberFormatter()
        formatter.locale = self.priceLocale
        formatter.numberStyle = .currency
        
        guard let price = formatter.string(from: self.price) else {
            return ""
        }
        return  price + "（月額）"
    }
}

protocol StoreManagerDelegate: class {

    func transactionOnPurchase(_ transaction:SKPaymentTransaction)
    func transactionDidDefer(_ transaction:SKPaymentTransaction)
    func transactionDidPurchase(_ transaction:SKPaymentTransaction, completed:@escaping()->Void)
    func transactionDidFail(_ transaction:SKPaymentTransaction, error:Error)
    func transactionDidRestore(_ transaction:SKPaymentTransaction, completed:@escaping()->Void)
    
}

protocol StoreManagerRestoreDelegate: class {
    func onSuccess()
    func onFailed(error: NSError)
    
}
class StoreManager: NSObject {
    
    public static let shared = StoreManager()
    weak var delegate: StoreManagerDelegate?
    weak var restoreDelegate: StoreManagerRestoreDelegate?
    
    private var _request: SKProductsRequest!
    @objc dynamic var products = [SKProduct]()
    
    static let PRODUCT_ID = "tokyo.reink.msgapp.basic"
    static let SECRET = "afbc22d79a0144f891dcb1f9815d50fa"
    
    var receiptString:String? {
        guard let url = Bundle.main.appStoreReceiptURL, let receipt = NSData(contentsOf: url) else {
            return nil
        }
        return receipt.base64EncodedString()
    }

    private func validateProductIdentifiers(with identifiers: [String]) {
        _request = SKProductsRequest(productIdentifiers: Set<String>(identifiers))
        _request.delegate = self
        _request.start()
    }

    func fetchProduct(by productIdentifier:String) -> SKProduct? {
        for p in self.products {
            if p.productIdentifier == productIdentifier {
                return p
            }
        }
        return nil
    }

    func fetchProducts() {
        guard let url = Bundle.main.url(forResource: "Products", withExtension: "plist") else {
            return
        }
        
        guard let pids = NSArray(contentsOf: url) as? [String] else {
            return
        }
        self.validateProductIdentifiers(with: pids)
    }
    
    func productName(by productIdentfier:String) -> String {
        
        if let prd = self.fetchProduct(by: productIdentfier) {
            return prd.localizedTitle
        } else {
            return NSLocalizedString("ProdcutNameFree", comment: "ProductName")
        }
    }
    
    func basicProduct() -> SKProduct? {
        return self.fetchProduct(by: StoreManager.PRODUCT_ID)
    }
    
    func purchase(product:SKProduct) {
        
        if SKPaymentQueue.canMakePayments() == false {
            
        }

        for t in SKPaymentQueue.default().transactions {
            if t.transactionState != .purchased { continue }
            if t.payment.productIdentifier == product.productIdentifier {
                
            }
        }
        
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = RealmManager.shared.user()!.uuid.sha256()
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        //SKPaymentQueue.default().restoreCompletedTransactions()
        self.refreshReceipt()
    }
    
    func refreshReceipt() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
    
    func openManagementSubscription() {
        if let url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/DirectAction/manageSubscriptions") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension StoreManager: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        APIManager.shared.updateReceipt(onSuccess: {
            self.restoreDelegate?.onSuccess()
        }, onFailure: {err in
            self.restoreDelegate?.onFailed(error: err)
        })
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.restoreDelegate?.onFailed(error: error as NSError)
    }
}

extension StoreManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        if let vc = (UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? ProductViewController) {
            vc.product = self.basicProduct()
        }

    }
}

extension StoreManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for t in transactions {
            
            switch t.transactionState {
            case .purchasing:
                
                self.delegate?.transactionOnPurchase(t)
                
            case .deferred:
                
                self.delegate?.transactionDidDefer(t)
            
            case .failed:
                self.delegate?.transactionDidFail(t, error: t.error!)
                SKPaymentQueue.default().finishTransaction(t)
            
            case .purchased:
                
                
                if let delegate = self.delegate {
                    delegate.transactionDidPurchase(t, completed: {
                        UserDefaultsManager.shared.restored = true
                        SKPaymentQueue.default().finishTransaction(t)
                    })
                } else {
                    UserDefaultsManager.shared.restored = true
                    SKPaymentQueue.default().finishTransaction(t)
                }
            
            case .restored:
                
                if let delegate = self.delegate {
                    delegate.transactionDidRestore(t, completed: {
                        UserDefaultsManager.shared.restored = true
                        SKPaymentQueue.default().finishTransaction(t)
                    })
                } else {
                    UserDefaultsManager.shared.restored = true
                    SKPaymentQueue.default().finishTransaction(t)
                }
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        UserDefaultsManager.shared.restored = true
        self.restoreDelegate?.onSuccess()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.restoreDelegate?.onFailed(error: error as NSError)
    }
}

