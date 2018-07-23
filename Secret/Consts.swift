//
//  Consts.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/27.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class Consts: NSObject {

    class var appErrDomain: String {
        return Bundle.main.bundleIdentifier!+".error"
    }
    
    class var termsURL: URL {
        return URL(string: "https://api.reink.tokyo/terms/")!
    }

    class var privacyURL: URL {
        return URL(string: "https://api.reink.tokyo/privacy/")!
    }
    

}
