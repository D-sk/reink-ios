//
//  HelpPageView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/11.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class HelpPageView: AbstractView {
    
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _descLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setPage(_ page:HelpPage) {
        _imageView.image = page.image
        _titleLabel.text = page.title
        _descLabel.text = page.desc
    }

}
