//
//  Group.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/04.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class Group: Object, NSCopying {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var colorKey = 4
    @objc dynamic var displayOrder = 0
    @objc dynamic var isEditable = true
    let friends = List<Friend>()
    let contacts = List<Contact>()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    func color() -> UIColor {
        return UIColor.Palette(rawValue: self.colorKey)!.color()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let g = Group()
        g.id = self.id
        g.name = self.name
        g.colorKey = self.colorKey
        g.displayOrder = self.displayOrder
        g.isEditable = self.isEditable
        
        for f in self.friends {
            g.friends.append(f.copy() as! Friend)
        }
        
        for c in self.contacts {
            g.contacts.append(c.copy() as! Contact)
        }
        return g
    }
    
}
