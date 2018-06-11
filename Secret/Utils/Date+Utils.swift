//
//  Date+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/14.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import Foundation

extension Date {

    func isSameYear(with date: Date) -> Bool {
        let a = Calendar.current.dateComponents([.year], from: self)
        let b = Calendar.current.dateComponents([.year], from: date)
        return a.year == b.year
    }
    
    func isSameDay(with date:Date) -> Bool {
        let a = Calendar.current.dateComponents([.year,.month,.day], from: self)
        let b = Calendar.current.dateComponents([.year,.month,.day], from: date)
        return a.year == b.year && a.month == b.month && a.day == b.day
    }
    
    func string() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        if self.isSameDay(with:Date()){
            dateFormatter.dateFormat = "HH:mm"
        }else if self.isSameYear(with: Date()){
            dateFormatter.dateFormat = "M月d日(EEE)"
        }else {
            dateFormatter.dateFormat = "YYYY年M月d日(EEE)"
        }
        return dateFormatter.string(from: self)
        
    }

}
