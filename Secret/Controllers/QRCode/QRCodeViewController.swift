//
//  QRCodeViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/09/24.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class QRCodeViewController: AbstractViewController {


    @IBOutlet weak var qrCodeView: QRCodeView!
    let transition:OverlayTransition = OverlayTransition()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transitioningDelegate = transition
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.qrCodeView.delegate = self
        if let a = RealmManager.shared.myAccount() {
            self.qrCodeView.setQRCode(account: a)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension QRCodeViewController: QRCodeViewDelegate {
    
    func closeButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
}
