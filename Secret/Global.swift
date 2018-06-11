//
//  Global.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/14.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import Foundation
import LocalAuthentication

func canUseFaceID() -> Bool {
    if #available(iOS 11.0, *) {
        let context = LAContext()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            if let e = error {
                print(e)
                return false
            }
            return context.biometryType == .faceID
        }
    }
    return false
}

func resetAll() {
    UserDefaultsManager.shared.clear()
    RealmManager.shared.deleteAll()
    KeychainManager.shared.clear()
}
