//
//  KeychainManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/04.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import LUKeychainAccess

class KeychainManager: NSObject {

    public static let shared: KeychainManager = KeychainManager()
    fileprivate let _keychain:LUKeychainAccess = LUKeychainAccess.standard()
    
    override init() {
        _keychain.accessibilityState = .attrAccessibleAlways
    }
    
//    public var uname:String {
//        get {
//            if let value = _keychain.object(forKey: "uname") as? String{
//                return  value
//            }
//            return ""
//        }
//        set {
//            if newValue.isEmpty {
//                _keychain.setObject(nil, forKey: "uname")
//            } else {
//                _keychain.setObject(newValue, forKey: "uname")
//            }
//        }
//    }
//
//    public var email:String {
//        get {
//            if let value = _keychain.object(forKey: "email") as? String{
//                return  value
//            }
//            return ""
//        }
//        set {
//            if newValue.isEmpty {
//                _keychain.setObject(nil, forKey: "email")
//            } else {
//                _keychain.setObject(newValue, forKey: "email")
//            }
//        }
//    }
//
//    public var uuid:String{
//        get {
//            if let value = _keychain.object(forKey: "uuid") as? String{
//                return  value
//            }
//            return ""
//        }
//        set {
//            if newValue.isEmpty {
//                _keychain.setObject(nil, forKey: "uuid")
//            } else {
//                _keychain.setObject(newValue, forKey: "uuid")
//            }
//        }
//    }
    
    public var authToken:String {
        get {
            if let value = _keychain.object(forKey: "authToken") as? String{
                return  value
            }
            return ""
        }
        set {
            if newValue.isEmpty {
                _keychain.setObject(nil, forKey: "authToken")
            } else {
                _keychain.setObject(newValue, forKey: "authToken")
            }
        }
    }
    
    public var receiptStatus: Int? {
        get {
            if let value = _keychain.object(forKey: "receiptStatus") as? Int {
                return  value
            }
            return nil
        }
        set {
            _keychain.setObject(newValue, forKey: "receiptStatus")
        }
    }
    
    func clear() {
        self.authToken = ""
        self.receiptStatus = nil
    }


}
