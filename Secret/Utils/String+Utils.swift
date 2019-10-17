//
//  String+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/23.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import Foundation

extension String {
    
    private func convertZenkakuToHankaku(reverse: Bool) -> String {
        
        let str = NSMutableString(string: self) as CFMutableString
        CFStringTransform(str, nil, kCFStringTransformFullwidthHalfwidth, reverse)
        return str as String
    }
    
    
    var hankaku: String {
        return convertZenkakuToHankaku(reverse: false)
    }
    
    var zenkaku: String {
        return convertZenkakuToHankaku(reverse: true)
    }
    
    func hiragana() -> String {
        var str = ""
        
        for c in unicodeScalars {
            if c.value >= 0x30A1 && c.value <= 0x30F6 {
                str += String(describing: UnicodeScalar(c.value - 96)!)
            } else {
                str += String(c)
            }
        }
        return str
    }
    
    func sha256() -> String {
        
        let cstr = self.cString(using: .utf8)
        let data = NSData(bytes: cstr!, length: self.utf8.count)
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256(data.bytes, CC_LONG(data.length), &digest)
        
        let output = NSMutableString(capacity: 64)
        for i in 0..<32 {
            output.appendFormat("%02x", digest[i])
        }
        
        return output as String
    }

    var isHirangana: Bool {
        let regexp = "^[ぁ-ゞ]+$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regexp)
        return predicate.evaluate(with: self)
    }
    
    var isAlphabet: Bool {
        let regex = "^[ａ-ｚＡ-Ｚa-zA-Z0-9!-/:-@\\[-`{-~\\s]+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }    

    var isAllHankaku: Bool {
        
        let charlen = self.count
        let utf8 = (self as NSString).utf8String!
        if charlen == strlen(utf8) {
            return true
        }
        
        return false
    }    
}
