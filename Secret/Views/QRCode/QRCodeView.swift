//
//  QRCodeView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/30.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import CoreImage

protocol QRCodeViewDelegate: class {
    func closeButtonDidTap()
}

class QRCodeView: AbstractView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!

    weak var delegate: QRCodeViewDelegate?
    fileprivate var _profile: Contact!

    /*
     @IBOutlet weak var imageView: UIImageView!
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func setup() {
        super.setup()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.closeButtonDidTap()
    }
    
    func setQRCode(with data:Data) {
        
        let qr = CIFilter(name: "CIQRCodeGenerator", withInputParameters: ["inputMessage": data, "inputCorrectionLevel": "L"])!
        let sizeTransform = CGAffineTransform(scaleX: 4, y: 4)
        let qrImage = qr.outputImage!.transformed(by: sizeTransform)
        self.imageView.image = UIImage(ciImage: qrImage)
        
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        delegate?.closeButtonDidTap()
    }
    
}
