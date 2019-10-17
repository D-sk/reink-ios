//
//  Contact.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift
import MessageUI

class Contact: Object, NSCopying {

    @objc dynamic var identifier:String = ""
    @objc dynamic var givenName:String = ""
    @objc dynamic var familyName:String = ""
    @objc dynamic var phonetic:String = ""
    @objc dynamic var imageData:Data?
    let phoneNumbers = List<PhoneNumber>()
    let emailAddresses = List<EmailAddress>()
    let groups = LinkingObjects(fromType: Group.self, property: "contacts")
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    class func object(from:CNContact) -> Contact {
        let c = Contact()
        c.identifier = from.identifier
        c.givenName = from.givenName
        c.familyName = from.familyName
        
        if from.phoneticFamilyName.isEmpty && from.phoneticGivenName.isEmpty {
            let phonetic = from.familyName+from.givenName
            let regex = "^[a-zA-Z0-9!-/:-@\\[-`{-~]+"
            let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
            if predicate.evaluate(with: phonetic) {
                c.phonetic = phonetic.uppercased()
            }else{
                c.phonetic = "#"
            }
        }else {
            let regex = "^[a-zA-Z]+"
            let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
            if predicate.evaluate(with: c.phonetic) {
                c.phonetic = c.phonetic.hankaku.uppercased()
            } else {
                c.phonetic = from.phoneticFamilyName.zenkaku.hiragana() + from.phoneticGivenName.zenkaku.hiragana()
            }
        }
        
        for pn in from.phoneNumbers {
            c.phoneNumbers.append(PhoneNumber.object(from:pn))
        }
        for ea in from.emailAddresses {
            c.emailAddresses.append(EmailAddress.object(from:ea))
        }
        c.imageData = from.imageData
        return c
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let c = Contact()
        c.identifier = self.identifier
        c.givenName = self.givenName
        c.familyName = self.familyName
        c.phonetic = self.phonetic
        c.imageData = self.imageData
        for p in self.phoneNumbers {
            c.phoneNumbers.append(p.copy() as! PhoneNumber)
        }
        for e in self.emailAddresses {
            c.emailAddresses.append(e.copy() as! EmailAddress)
        }
        return c
    }

    func fullName() -> String {
        return self.familyName + " " + self.givenName
    }
    
    func thumbnail() -> UIImage?{
        if let data = self.imageData{
            return UIImage(data: data)
        }
        return nil
    }

}

extension Contact {
    
    func phoneActionController(phoneAction:@escaping (_ digit: String)->Void) ->UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for pn in self.phoneNumbers {
            let pa = UIAlertAction(title:pn.digits, style: .default, handler:{(action:UIAlertAction!) -> Void in
                phoneAction(pn.digits)
            })
            alertController.addAction(pa)
        }
        let cancel =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil)
        alertController.addAction(cancel)
        return alertController
    }
    
    func mailActionController(mailAction:@escaping (_ value: String)->Void) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for ea in self.emailAddresses {
            let ma = UIAlertAction(title:ea.value, style: .default, handler:{(action:UIAlertAction!) -> Void in
                mailAction(ea.value)
            })
            alertController.addAction(ma)
        }
        let cancel =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil)
        alertController.addAction(cancel)
        return alertController
    }
}


