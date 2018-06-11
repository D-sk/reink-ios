//
//  Message.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/12/27.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class Message: Object {

    dynamic var id: Int = 0
    dynamic var sender:Account?
    dynamic var body:String = ""
    dynamic var createdAt:Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func object(from:Dictionary<String,Any>) -> Message {
        let msg = Message()
        msg.id = from["id"] as! Int
        msg.body = from["body"] as! String
        msg.createdAt = DateFormatter.api().date(from: from["created_at"] as! String)!
        if let acc_id = from["sender"] as? Int {
            msg.sender = RealmManager.shared.account(with: acc_id)
        }
        return msg
    }
 
    func receivedAt() -> String {
        return self.createdAt.string()
    }
    
}

extension Message {
    
    class func list(with friend:Friend, onSuccess:@escaping([Message])->Void, onFailure:@escaping(_ error:NSError)->Void){
        APIManager.shared.messages(with: friend, onSuccess: { objects in
            var msgs = [Message]()
            for obj in objects{
                let msg = Message.object(from: obj)
                if msg.sender!.id == friend.account!.id {
                    msgs.append(msg)
                }
            }
            onSuccess(msgs)

        }, onFailure: { err in
            onFailure(err)
            
        })
    }
    
    func get(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
    }
    
    
    func delete(onSuccess:@escaping()->Void, onFailure:@escaping(_ error:NSError)->Void){
        APIManager.shared.deleteMessage(message: self, onSuccess: {
            onSuccess()
        }, onFailure: { err in
            onFailure(err)
        })
    }
    
}
