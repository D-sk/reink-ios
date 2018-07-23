//
//  UserDefaultsManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/15.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class UserDefaultsManager: NSObject {
    
    public static let shared: UserDefaultsManager = UserDefaultsManager()
    fileprivate let _userdefaults = UserDefaults.standard
    
    public var isFirstOpen:Bool {
        get {
            if let value = _userdefaults.object(forKey: "isFirstOpen") as? Bool{
                return  value
            }
            return true
        }
        set {
            _userdefaults.set(newValue, forKey: "isFirstOpen")
            _userdefaults.synchronize()
        }
    }
    
    public var isFirstLogin:Bool {
        get {
            if let value = _userdefaults.object(forKey: "isFirstLogin") as? Bool{
                return  value
            }
            return false
        }
        set {
            _userdefaults.set(newValue, forKey: "isFirstLogin")
            _userdefaults.synchronize()
        }

    }

    public var restored:Bool {
        get {
            if let value = _userdefaults.object(forKey: "restored") as? Bool{
                return  value
            }
            return false
        }
        set {
            _userdefaults.set(newValue, forKey: "restored")
            _userdefaults.synchronize()
        }
        
    }

    public var passcode:Bool {
        get {
            if let value = _userdefaults.object(forKey: "passcode") as? Bool{
                return  value
            }
            return false
        }
        set {
            _userdefaults.set(newValue, forKey: "passcode")
            _userdefaults.synchronize()
        }
    }

    func clear(){
        _userdefaults.synchronize()
    }

}
