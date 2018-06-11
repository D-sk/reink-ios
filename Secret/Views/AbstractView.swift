//
//  AbstractView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class AbstractView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        backgroundColor = UIColor.clear
        
        let view = instantiate(withOwner: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        let views = ["v": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: .alignAllCenterY, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: .alignAllCenterY, metrics: nil, views: views))
    }
}
