//
//  ProductView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/04/15.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import StoreKit

protocol ProductViewDelegate:class {
    func buyDidTap()
    func cancelDidTap()
}

class ProductView: AbstractView {

    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _priceLabel: UILabel!
    @IBOutlet weak var _bodyLabel: UILabel!
    @IBOutlet weak var _buyButton: UIButton!
    @IBOutlet weak var _cancelButton: UIButton!
    
    weak var delegate:ProductViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        super.setup()
        self.isHidden = true
    }
    
    func setProduct(with product:SKProduct) {
        _titleLabel.text = product.localizedTitle
        _priceLabel.text = product.priceString()
        _bodyLabel.text = product.localizedDescription
        self.isHidden = false
    }

    @IBAction func buyButtonDidTap(_ sender: Any) {
        delegate?.buyDidTap()
    }

    @IBAction func cancelButtonDidTap(_ sender: Any) {
        delegate?.cancelDidTap()
    }

}
