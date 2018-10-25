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

    enum Membership: Int {
        case special = 1
        case basic = 2
        case none = 0
    }
    
    dynamic var id:Int = 0
    dynamic var name:String = ""
    dynamic var imagePath:String?
    dynamic var phone:String = ""
    dynamic var email:String = ""
    dynamic var membership:Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func object(from:Dictionary<String,Any>) -> Account {
        let acc = Account()
        acc.id = from["id"] as! Int
        acc.name = from["name"] as! String
        acc.phone = from["phone"] as! String
        acc.email = from["email"] as! String
        acc.imagePath = from["thumbnail"] as? String
        
        if let membership = from["membership"] as? Int {
            acc.membership = membership
        }
        
        return acc
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let acc = Account()
        acc.id = self.id
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
    
    func needsRestore() -> Bool{
        return UserDefaultsManager.shared.restored == false && self.membership == 2
    }

}

// MARK: - API
extension Account {
    
    static func syncMyAccount() {
        if let me = RealmManager.shared.myAccount() {
            me.get(onSuccess: {}, onFailure: { err in })
        }
    }
    
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
            RealmManager.shared.saveUserAccount(with: Account.object(from: dict))
            onSuccess()

        }, onFailure: { err in
            onFailure(err)
        
        })
    }
    
    func update(with thumbnail:UIImage?, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void) {
        APIManager.shared.updateAccount(account: self, withThumbnail: thumbnail, onSuccess: { dict in
            RealmManager.shared.saveAccount(with: Account.object(from: dict))
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
