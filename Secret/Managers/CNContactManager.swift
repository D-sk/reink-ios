//
//  CNContactManager.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/13.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Contacts

class CNContactManager: NSObject {
    
    static let shared = CNContactManager()
    fileprivate let _store = CNContactStore.init()
    
    func authorizedStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAccess(onGrant: (()->Void)?, onError:((Error)->Void)?) {
        _store.requestAccess(for: .contacts, completionHandler: {(granted, error) in
            if granted {
                onGrant?()
            }else if error != nil {
                onError?(error!)
            }
        })
    }
    
    func sync() {
        
        RealmManager.shared.createGroupAllIfNeeded()
        
        let status = authorizedStatus()
        switch status {
        case .notDetermined, .restricted:
            self.requestAccess(onGrant:{
                self.fetchContacts()
            }, onError: nil)
        case .denied:
            break
        case .authorized:
            return self.fetchContacts()
        }
    }
    
    private func fetchContacts(){
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor,
                                                              CNContactFamilyNameKey as CNKeyDescriptor,
                                                              CNContactPhoneticGivenNameKey as CNKeyDescriptor,
                                                              CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
                                                              CNContactPhoneNumbersKey as CNKeyDescriptor,
                                                              CNContactEmailAddressesKey as CNKeyDescriptor,
                                                              CNContactImageDataKey as CNKeyDescriptor])
            
            request.sortOrder = .userDefault
            
            var contacts = [Contact]()
            try _store.enumerateContacts(with: request, usingBlock: {(contact, cursor) in
                contacts.append(Contact.object(from: contact))
            })
            RealmManager.shared.saveContacts(with: contacts)
        }
        catch{
            print("連絡先データの取得に失敗しました")
        }
    }
    
}
