//
//  UIApplicatoin+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/07/29.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

}
