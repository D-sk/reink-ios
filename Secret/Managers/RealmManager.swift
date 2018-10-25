//
//  RealmManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/23.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class RealmManager: NSObject {
    static let shared = RealmManager()
    fileprivate let _realm = try! Realm()
    
    func asyncSaveObjects<T: Object>(type:T.Type, objects:[T]) {
        DispatchQueue.init(label: "background").async {
            let realm = try! Realm()
            
            guard let grp = realm.objects(Group.self).filter("displayOrder = %@", 0).first else {
                return
            }
            
            try! realm.write {
                
                var newObjects = [T]()
                var delObjects = [T]()
                let exists = realm.objects(type)

                switch type {
                case is Friend.Type:
                    
                    realm.add(objects, update: true)
                    let existIds = Array(exists).map{ ($0 as! Friend).id }
                    for obj in objects {
                        let frd = obj as! Friend
                        if frd.isUnlinked {
                            if let _ = existIds.index(of: frd.id) {
                                delObjects.append(obj)
                            }
                        } else {
                            if grp.friends.index(of: obj as! Friend) == nil {
                                newObjects.append(obj)
                            }
                        }
                    }
                    grp.friends.append(objectsIn: newObjects as! [Friend])
                    realm.delete(delObjects)
                    
                case is Contact.Type:
                    
                    realm.add(objects, update: true)
                    for obj in objects {
                        if grp.contacts.index(of: obj as! Contact) == nil {
                            newObjects.append(obj)
                        }
                    }
                    grp.contacts.append(objectsIn: newObjects as! [Contact])
                    
                    let exists = realm.objects(type)
                    let newIds = objects.map{ ($0 as! Contact).identifier }
                    for obj in exists {
                        let c = obj as! Contact
                        if newIds.index(of: c.identifier) == nil {
                            delObjects.append(obj)
                        }
                    }
                    realm.delete(delObjects)

                default:
                    break
                }
            }
        }
    }
    
    fileprivate func saveObject(object: Object, update:Bool) {

        try! _realm.write {
            _realm.add(object, update:update)
            
            guard let grp = self.groupAll() else {
                return
            }
            switch object {
            case is Friend:
                let frd = object as! Friend
                if frd.isUnlinked {
                    frd.defectFromGroups()
                } else {
                    if grp.friends.index(of: frd) == nil {
                        grp.friends.append(object as! Friend)
                    }
                }
            case is Contact:
                if grp.contacts.index(of: object as! Contact) == nil {
                    grp.contacts.append(object as! Contact)
                }
            default:
                break
            }
        }
    }
    
    func deleteAll(){
        try! _realm.write {
            _realm.deleteAll()
        }
    }
    
    
    // User
    func saveUser(with user: User){
        try! _realm.write {
            _realm.add(user, update: true)
        }
    }
    
    func user() -> User? {
        return _realm.objects(User.self).first
    }
    
    func updateUserEmail(with email:String) {
        guard let usr = self.user() else {
            return
        }
        try! _realm.write {
            usr.email = email
        }
    }
    
    
    func saveUserAccount(with account: Account) {
        guard let usr = self.user() else {
            return
        }
        try! _realm.write {
            usr.account = account
        }
    }
    
    // Account
    func saveAccount(with account: Account){
        try! _realm.write {
            _realm.add(account, update: true)
        }
    }
    
    func myAccount() -> Account? {
        return self.user()?.account
    }

    func account(with id:Int) -> Account? {
        return _realm.objects(Account.self).filter("id=%@", id).first
    }

    
    // Friend
    func saveFriend(with friend:Friend){
        self.saveObject(object: friend, update: true)
    }
    
    func saveFriends(with dictArray:[Dictionary<String,Any>]) {
        var friends = [Friend]()
        for dict in dictArray  {
            friends.append(Friend.object(from: dict))
        }
        self.asyncSaveObjects(type: Friend.self, objects: friends)
    }

    func updateMessageCount(of friend:Friend, to:Int) {
        try! _realm.write {
            friend.messageCount = to
        }
    }

    func deleteFriend(_ friend:Friend) {
        try! _realm.write {
            _realm.delete(friend)
        }
    }
    
    func friends() -> Results<Friend>{
        return _realm.objects(Friend.self).filter("isUnlinked=false").sorted(byKeyPath: "receivedAt", ascending: false)
    }
    
    func friend(with id:Int) -> Friend? {
        return _realm.objects(Friend.self).filter("id=%@", id).first
    }

    func friends(with word:String) -> Results<Friend> {
        let accounts = _realm.objects(Account.self).filter("name CONTAINS[c] %@ OR name CONTAINS[c] %@", word, word)
        return _realm.objects(Friend.self).filter("account IN %@", accounts)
    }

    func latestUpdatedFriend() -> Friend? {
        return _realm.objects(Friend.self).sorted(byKeyPath: "updatedAt", ascending: false).first
    }
    
    func messageCount() -> Int {
        var count = 0
        for frd in self.friends() {
            count += frd.messageCount
        }
        return count
    }

    // Contact
    func saveContact(_ contact:Contact){
        self.saveObject(object: contact, update: true)
    }
    
    func saveContacts(with contacts:[Contact]) {
        self.asyncSaveObjects(type: Contact.self, objects: contacts)
    }

    func contacts() -> Results<Contact>{
        return _realm.objects(Contact.self).sorted(byKeyPath: "phonetic")
    }
    
    func contacts(with word:String) -> Results<Contact> {
        return _realm.objects(Contact.self).filter("givenName CONTAINS[c] %@ OR familyName CONTAINS[c] %@ OR phonetic CONTAINS[c] %@", word, word, word)
    }


    //Group
    func createGroupAllIfNeeded() {
        let name = NSLocalizedString("GroupNameAll", comment: "GroupName")
        if self.groupAll() == nil {
            let grp = Group()
            grp.name = name
            grp.colorKey = UIColor.Palette.green.rawValue
            grp.isEditable = false
            try! _realm.write {
                _realm.add(grp)
            }
        }
    }
    
    func saveGroups(with groups:[Group]) {
        try! _realm.write {
            for (idx, grp) in groups.enumerated() {
                grp.displayOrder = idx
            }
            _realm.add(groups, update: true)
        }
    }
    
    func saveGroup(with group:Group) {
        try! _realm.write {
            _realm.add(group, update: true)
        }        
    }
    
    func deleteGroup(_ group:Group) {
        try! _realm.write {
            _realm.delete(group)
        }
    }
    
    func groupAll() -> Group? {
        return _realm.objects(Group.self).filter("displayOrder = %@", 0).first
    }
    
    func groups() -> Results<Group> {
        return _realm.objects(Group.self).sorted(byKeyPath: "displayOrder")
    }
    
}
