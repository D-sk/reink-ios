//
//  ProductViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/04/15.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import StoreKit

class ProductViewController: AbstractViewController {

    @IBOutlet weak var _productView: ProductView!
    let transition:OverlayTransition = OverlayTransition()
    var product:SKProduct?
//    {
//        didSet {
//            _productView.setProduct(with: product!)
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transitioningDelegate = transition
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _productView.delegate = self
        StoreManager.shared.delegate = self
        self.product = StoreManager.shared.basicProduct()
        if self.product != nil {
            _productView.setProduct(with: product!)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StoreManager.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.product = StoreManager.shared.basicProduct()
        if self.product != nil {
            _productView.setProduct(with: product!)
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        StoreManager.shared.delegate = nil
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProductViewController: StoreManagerDelegate {
    
    func transactionOnPurchase(_ transaction: SKPaymentTransaction) {
        self.addLoadingView(self.view.bounds)
    }
    
    func transactionDidDefer(_ transaction: SKPaymentTransaction) {
        
    }
    
    func transactionDidPurchase(_ transaction: SKPaymentTransaction, completed: @escaping () -> Void) {
        APIManager.shared.updateReceipt(onSuccess: {
            self.removeLoadingView()
            completed()
        }, onFailure: { err in
            self.removeLoadingView()
            self.present(AlertManager.shared.alertController(err), animated: true, completion: nil)
        })

    }
    
    func transactionDidFail(_ transaction: SKPaymentTransaction, error: Error) {
        let ac = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        self.present(ac, animated: true, completion: {
            self.removeLoadingView()
        })
    }
    
    func transactionDidRestore(_ transaction: SKPaymentTransaction, completed: @escaping () -> Void) {
        APIManager.shared.updateReceipt(onSuccess: {
            self.removeLoadingView()
            completed()
        }, onFailure: {err in
            self.removeLoadingView()
            self.present(AlertManager.shared.alertController(err), animated: true, completion: nil)
        })
    }
}

extension ProductViewController: ProductViewDelegate {
    func buyDidTap() {
        StoreManager.shared.purchase(product: self.product!)
    }
    
    func cancelDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
}
