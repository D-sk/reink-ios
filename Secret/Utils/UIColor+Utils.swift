
//
//  UIColor+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/27.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat=1.0) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    public convenience init(hex: String, alpha: CGFloat=1.0) {
        let hexStr = hex.replacingOccurrences(of: "#", with: "")
        
        let scanner = Scanner(string: hexStr)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: alpha)
        } else {
            fatalError("invalid hex string")
        }
    }

}

extension UIColor {
    public static let textDark = UIColor.Palette.black.color()
    public static let textLight = UIColor.Palette.lightBlack.color()
    public static let uiTint = UIColor.Palette.green.color()
    public static let uiLight = UIColor.Palette.gray.color()
    public static let background = UIColor.Palette.offwhite.color()
    public static let separator = UIColor.Palette.gray.color()
    public static let overlay = UIColor(hex: "#333333", alpha: 0.5)
}

extension UIColor {
    enum Palette: Int {
        case black = 0
        case red = 1
        case pink = 2
        case yellow = 3
        case green = 4
        case blue = 5
        case navy = 6
        case purple = 7
        case offwhite = 8
        case gray = 9
        case lightBlack = 10
        case lightRed = 11
        case lightPink = 12
        case lightYellow = 13
        case lightGreen = 14
        case lightBlue = 15
        case lightNavy = 16
        case lightPurple = 17
        case lightGray = 19

        public static let all:Array<Palette> = [
            .black,
            .red,
            .pink,
            .yellow,
            .green,
            .blue,
            .navy,
            .purple,
        ]
        
        func color() -> UIColor{
            switch self{
            case .black: return UIColor(hex: "#333333")
            case .red: return UIColor(hex: "#E22040")
            case .pink: return UIColor(hex: "#FF80A8")
            case .yellow: return UIColor(hex: "#FFE840")
            case .green: return UIColor(hex: "#00A4A4")
            case .blue: return UIColor(hex: "#0080FF")
            case .navy: return UIColor(hex: "#101054")
            case .purple: return UIColor(hex: "#6000E8")
            case .gray: return UIColor(hex: "#CCCCCC")
            case .offwhite: return UIColor(hex: "#FAFAFA")
            case .lightBlack: return UIColor(hex: "#808080")
            case .lightRed: return UIColor(hex: "#E2807F")
            case .lightPink: return UIColor(hex: "#FFC8C8")
            case .lightYellow: return UIColor(hex: "#FFFF80")
            case .lightGreen: return UIColor(hex: "#80E8E8")
            case .lightBlue: return UIColor(hex: "#A4D8FF")
            case .lightNavy: return UIColor(hex: "#78A8FF")
            case .lightPurple: return UIColor(hex: "#A4A4FF")
            case .lightGray: return UIColor(hex: "#F0F0F0")
            }
        }
        
        func title() -> String {
            let comment = "ColorPaletteTitle"
            let key = comment + String(self.rawValue)
            return NSLocalizedString(key, comment: comment)
        }
    }
    
    class func paletteColor(key:String) -> UIColor {
        if key.isEmpty == false {
            let char = String(key.first!)
            let value = Int(char.utf8.first!)
            return Palette(rawValue: value % 7 + 1)!.color()
        } else {
            return UIColor.lightGray
        }
    }
}
