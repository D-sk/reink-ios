//
//  PhoneNumber.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/11.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift

class PhoneNumber: Object, NSCopying {
    @objc dynamic var label = ""
    @objc dynamic var digits = ""
    
    class func object(from:CNLabeledValue<CNPhoneNumber>)->PhoneNumber{
        let pn = PhoneNumber()
        if from.label != nil {
            pn.label = CNLabeledValue<NSString>.localizedString(forLabel: from.label!)
        }
        pn.digits = from.value.stringValue
        return pn
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let p = PhoneNumber()
        p.label = self.label
        p.digits = self.digits
        return p
    }


}
