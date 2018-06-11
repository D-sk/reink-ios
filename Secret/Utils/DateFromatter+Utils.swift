//
//  DateFromatter+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/27.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    class func api() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}
