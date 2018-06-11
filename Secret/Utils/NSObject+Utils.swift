//
//  NSObject+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/23.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import Foundation

extension NSObject {
    
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
    
}
