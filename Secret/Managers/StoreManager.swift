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
    dynamic var products = [SKProduct]()
    
    static let PRODUCT_ID = "co.fiole.renk.basic"
    static let SECRET = "4b4a533bd1c24ba592beaa1ee1239fc6"
    
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
        payment.applicationUsername = KeychainManager.shared.uuid.sha256()
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

        for id in response.invalidProductIdentifiers {
            debugPrint(id)
        }
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
                
                self.delegate?.transactionDidPurchase(t, completed: {
                    SKPaymentQueue.default().finishTransaction(t)
                })
                
            
            case .restored:
                
                self.delegate?.transactionDidRestore(t, completed: {
                    SKPaymentQueue.default().finishTransaction(t)
                })
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.restoreDelegate?.onSuccess()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.restoreDelegate?.onFailed(error: error as NSError)
    }
    
}

//extension StoreManager {
//    func verifyRecipt() {
//
//        guard let url = Bundle.main.appStoreReceiptURL, let receipt = NSData(contentsOf: url) else {
//            return
//        }
//
//        #if DEBUG
//        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
//        #else
//        let urlString = "https://buy.itunes.apple.com/verifyReceipt"
//        #endif
//
//        guard let reqURL = URL(string: urlString) else {
//            return
//        }
//
//        var req = URLRequest(url: reqURL)
//        req.httpMethod = "POST"
//        let params = [
//            "receipt-data": receipt.base64EncodedString(),
//            "password": StoreManager.SECRET
//        ]
//        debugPrint(receipt.base64EncodedString())
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
//            req.httpBody = jsonData
//            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, res ,err in
//
//                if err != nil {
//                    debugPrint(err!)
//                    return
//                }
//
//                if data != nil {
//                    do {
//                        guard let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
//                            return
//                        }
//                        debugPrint(dict)
//                    } catch (let e) {
//                        debugPrint(e)
//                    }
//                }
//
//            })
//            task.resume()
//
//        } catch (let err) {
//            debugPrint(err)
//        }
//
//    }
//}
