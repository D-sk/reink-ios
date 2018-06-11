//
//  CALayer+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/30.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

extension CALayer {
    
    func setBorderIBColor(color: UIColor!) -> Void{
        self.borderColor = color.cgColor
    }
    
}
