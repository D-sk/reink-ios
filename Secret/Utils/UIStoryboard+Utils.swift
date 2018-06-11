//
//  UIStoryboard+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/14.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {

    class func main() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }

}

protocol StoryBoardInstantiatable {}
extension UIViewController: StoryBoardInstantiatable {}
extension StoryBoardInstantiatable where Self: UIViewController {
    
    static func instantiate() -> Self {
        return UIStoryboard.main().instantiateViewController(withIdentifier: self.className) as! Self
    }
    
    static func inistantiate(withIdentifier identifier: String) -> Self {
        return UIStoryboard.main().instantiateViewController(withIdentifier: identifier) as! Self
    }
    
}

