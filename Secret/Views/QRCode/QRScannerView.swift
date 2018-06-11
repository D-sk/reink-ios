//
//  QRScannerView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/01.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol QRScannerViewDelegate: class {
    func closeButtonDidTap()
    
}

class QRScannerView: AbstractView {

    weak var delegate: QRScannerViewDelegate?
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func addVideoPreviewLayer(layer:CALayer){
        
        self.videoView.layer.addSublayer(layer)

    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        delegate?.closeButtonDidTap()
    }

}
