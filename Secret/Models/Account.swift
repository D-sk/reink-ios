//
//  Account.Swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/14.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class Account: Object, NSCopying {

    dynamic var id:Int = 0
    dynamic var uname:String = ""
    dynamic var name:String = ""
    dynamic var imagePath:String?
    dynamic var phone:String = ""
    dynamic var email:String = ""
    dynamic var subscribed:String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func object(from:Dictionary<String,Any>) -> Account {
        let acc = Account()
        acc.id = from["id"] as! Int
        acc.uname = from["user"] as! String
        acc.name = from["name"] as! String
        acc.phone = from["phone"] as! String
        acc.email = from["email"] as! String
        acc.imagePath = from["thumbnail"] as? String
        
        if let subscribed = from["subscribed"] as? String {
            acc.subscribed = subscribed
        }
        
        return acc
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let acc = Account()
        acc.id = self.id
        acc.uname = self.uname
        acc.name = self.name
        acc.imagePath = self.imagePath
        acc.phone = self.phone
        acc.email = self.email
        return acc
    }
    
    func objToDict() -> Dictionary<String,String> {
        var dict = [String:String]()
        dict["name"] = self.name
        dict["phone"] = self.phone
        dict["email"] = self.email
        return dict
    }
    
    func imageURL() -> URL? {
        guard let path =  self.imagePath  else {
            return nil
        }
        return URL(string:path)
    }
    
    func qrCodeData() -> Data? {
        var dict = [String:Any]()
        dict["uname"] = self.uname
        dict["uuid"] = KeychainManager.shared.uuid
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: []) //(*)options??
            return jsonData
        } catch {
            print("Error!: \(error)")
        }
        return nil
    }

}

// MARK: - API
extension Account {
    
    func get(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void) {
        APIManager.shared.account(with: self.id, onSuccess: { dict in
            RealmManager.shared.saveAccount(with: Account.object(from: dict))
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
        })        
    }
    
    func create(with thumbnail:UIImage?, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void) {
        APIManager.shared.createAccount(self, withThumbnail: thumbnail, onSuccess: { dict in
            RealmManager.shared.saveAccount(with: self)
            onSuccess()

        }, onFailure: { err in
            onFailure(err)
        
        })
    }
    
    func update(with thumbnail:UIImage?, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void) {
        APIManager.shared.updateAccount(account: self, withThumbnail: thumbnail, onSuccess: { dict in
            RealmManager.shared.saveAccount(with: self)
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
        })
        
    }
    
    func delete(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void) {
        APIManager.shared.deleteAccount(account: self, onSuccess: {
            RealmManager.shared.deleteAll()
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
        })
    }

}
