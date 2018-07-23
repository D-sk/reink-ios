//
//  Friend.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/11.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift
import AVFoundation

class Friend: Object, NSCopying {
    
    dynamic var id:Int = 0
    dynamic var account:Account?
    dynamic var updatedAt:Date?
    dynamic var receivedAt:Date?
    dynamic var messageCount:Int = 0
    dynamic var isMuted:Bool = false
    dynamic var isUnlinked:Bool = false

    let groups = LinkingObjects(fromType: Group.self, property: "friends")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func object(from:Dictionary<String,Any>) -> Friend {
        let frd = Friend()
        frd.id = from["id"] as! Int
        if let acc = from["friend"] as? Dictionary<String,Any> {
            frd.account = Account.object(from: acc)
        }
        if let dateStr = from["updated_at"] as? String {
            frd.updatedAt = DateFormatter.api().date(from: dateStr)!
        }
        if let dateStr = from["received_at"] as? String {
            frd.receivedAt = DateFormatter.api().date(from: dateStr)!   
        }
        frd.messageCount = from["message_count"] as! Int
        frd.isMuted = from["is_muted"] as! Bool
        frd.isUnlinked = from["is_unlinked"] as! Bool
        return frd
    }

    func objToDict() -> Dictionary<String,Any> {
        var dict = [String:Any]()
        dict["id"] = self.id
        dict["isMuted"] = self.isMuted
        dict["isUnlinked"] = self.isUnlinked
        return dict
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let f = Friend()
        f.id = self.id
        f.account = self.account
        f.receivedAt = self.receivedAt
        f.messageCount = self.messageCount
        f.isMuted = self.isMuted
        return f
    }
    
    func receivedAtString() -> String {
        if self.receivedAt == nil {
            return ""
        }
        return self.receivedAt!.string()
    }
}

// MARK: - Realm Operation (can not call without transaction)
extension Friend {
    func defectFromGroups() {
        for grp in self.groups {
            guard let idx = grp.friends.index(of: self) else {
                continue
            }
            grp.friends.remove(at: idx)
        }
    }
    
}

// MARK: - API
extension Friend {
    
    class func list(onSuccess:(()->Void)?, onFailure:((_ error:NSError)->Void)?) {
        let latest = RealmManager.shared.latestUpdatedFriend()
        
        APIManager.shared.friends(updatedAt:latest?.updatedAt, onSuccess: { objects in
            RealmManager.shared.saveFriends(with: objects)
            onSuccess?()
        }, onFailure: { err in
            onFailure?(err)
        })
        
    }
    
    class func create(with metadataObj:AVMetadataMachineReadableCodeObject, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        if let json = metadataObj.stringValue{
            do {
                let dict = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String: Any]
                APIManager.shared.createFriend(params: dict, onSuccess: { dict in
                    RealmManager.shared.saveFriend(with: Friend.object(from: dict))
                    onSuccess()
                }, onFailure: { err in
                    onFailure(err)
                })
                
            } catch {
                let err = NSError(domain: Consts.appErrDomain, code: 500, userInfo: nil)
                onFailure(err)
                
            }
        }
    }

    func get(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        APIManager.shared.retreiveFriend(self, onSuccess: { dict in
            RealmManager.shared.saveAccount(with: Account.object(from: dict))
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
        })
    }

    
    func sendMessage(_ message:String, onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        APIManager.shared.sendMessage(to: self, body: message, onSuccess: {
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
        })
    }
    
    func mute(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        APIManager.shared.muteFriend(self, onSuccess: { dict in
            RealmManager.shared.saveFriend(with: Friend.object(from: dict))
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
            
        })
    }
    
    func unlink(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        APIManager.shared.unlinkFriend(self, onSuccess: { dict in
            RealmManager.shared.saveFriend(with: Friend.object(from: dict))
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
            
        })
    }
    
    func delete(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        APIManager.shared.deleteFriend(self, onSuccess: {
            RealmManager.shared.deleteFriend(self)
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
        })
    }

}
