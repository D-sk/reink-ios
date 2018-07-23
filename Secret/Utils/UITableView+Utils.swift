//
//  UITableView+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/26.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(type: T.Type) {
        let className = type.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    
    func registerCells<T: UITableViewCell>(types: [T.Type]) {
        types.forEach { registerCell(type: $0) }
    }
    
    func dequeueCell<T: UITableViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }

    func dequeueCell<T: UITableViewCell>(type: T.Type) -> T {
        return self.dequeueReusableCell(withIdentifier: type.className) as! T
    }
    
    func setBlurEffect(){
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.backgroundView = blurEffectView
        self.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
}
