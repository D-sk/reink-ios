//
//  HelpBook.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/11.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

enum HelpBook: String {
    case friend = "Friend"
    case message = "Message"
    case group = "Group"
    
    public static let all: [HelpBook] = [
        .friend,
        .message,
        .group
    ]
    
    func numberOfPages() -> Int {
        switch self {
        case .friend: return 3
        case .message: return 3
        case .group: return 3
        }
    }
    
    func title() -> String {
        let comment = "HelpBookTitle"
        let key = comment + self.rawValue
        return NSLocalizedString(key, comment: comment)
    }
    
    func pages() -> [HelpPage] {
        var pages = [HelpPage]()
        for p in 1...self.numberOfPages() {
            let base = "HelpPage"
            let tc = base+"Title" 
            let dc = base+"Desc"
            
            var hp = HelpPage()
            hp.image = UIImage(named: String(format: base+self.rawValue+"%d", p))
            hp.title = NSLocalizedString(String(format: tc+self.rawValue+"%d", p), comment: tc)
            hp.desc = NSLocalizedString(String(format: dc+self.rawValue+"%d", p), comment: dc)
            pages.append(hp)
        }
        return pages
    }
}
