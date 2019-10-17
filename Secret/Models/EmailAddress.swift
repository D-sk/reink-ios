//
//  EmailAddress.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/11.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift

class EmailAddress: Object, NSCopying {
    @objc dynamic var label = ""
    @objc dynamic var value = ""
    
    class func object(from:CNLabeledValue<NSString>)->EmailAddress{
        let ea = EmailAddress()
        if from.label != nil {
            ea.label = CNLabeledValue<NSString>.localizedString(forLabel: from.label!)
        }
        ea.value = from.value as String
        return ea
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let e = EmailAddress()
        e.label = self.label
        e.value = self.value
        return e
    }

}
