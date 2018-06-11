//
//  UIView+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/23.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import Foundation
import UIKit

protocol NibInstantiatable {}
extension UIView: NibInstantiatable {}

extension NibInstantiatable where Self: UIView {
    
    static func instantiate(withOwner ownerOrNil: Any? = nil) -> UIView {
        return UINib.instantiate(nibName: self.className, ownerOrNil: ownerOrNil)
    }
    
    static func instantiate(identifier: String, withOwner ownerOrNil: Any? = nil) -> UIView {
        return UINib.instantiate(nibName: identifier, ownerOrNil: ownerOrNil)
    }
    
    func instantiate(withOwner ownerOrNil: Any? = nil) -> UIView {
        return UINib.instantiate(nibName: self.className, ownerOrNil: ownerOrNil)
    }
    
    func instantiate(identifier: String, withOwner ownerOrNil: Any? = nil) -> UIView {
        return UINib.instantiate(nibName: identifier, ownerOrNil: ownerOrNil)
    }
    
}

extension UINib {
    
    static func instantiate(nibName: String, ownerOrNil: Any? = nil) -> UIView {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: ownerOrNil, options: nil)[0] as! UIView
    }
    
}
