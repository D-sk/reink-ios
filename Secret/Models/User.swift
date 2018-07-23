//
//  User.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/23.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {

    dynamic var uuid: String = ""
    dynamic var uname: String = ""
    dynamic var email: String = ""
    dynamic var account: Account?
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    class func object(from:Dictionary<String,Any>) -> User {
        let usr = User()
        usr.uuid = from["uuid"] as! String
        usr.uname = from["username"] as! String
        
        if let email = from["email"] as? String {
            usr.email = email
        }
        
        if let dict = from["account"] as? Dictionary<String, Any> {
            usr.account = Account.object(from: dict)
        }

        return usr
    }
    
    func qrCodeData() -> Data? {
        var dict = [String:Any]()
        dict["uuid"] = self.uuid
        dict["username"] = self.uname
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: []) //(*)options??
            return jsonData
        } catch {
            print("Error!: \(error)")
        }
        return nil
    }
}
