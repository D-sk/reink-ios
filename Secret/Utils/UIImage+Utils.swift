//
//  UIImage+Utils.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/04.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func data() -> Data {
        
        let height:CGFloat = 192.0
        let width: CGFloat = 192.0
        
        var rect = CGRect.zero
        if self.size.width < self.size.height {
            rect.size.width = width
            rect.size.height = self.size.height * (width/self.size.width)
        } else {
            rect.size.height = height
            rect.size.width = self.size.width * (height/self.size.height)
        }
        
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let cropRect = CGRect(x: (rect.size.width-width)/2, y: (rect.size.height-height)/2, width: width, height: height)
        let thumbnail = UIImage(cgImage: newImage!.cgImage!.cropping(to: cropRect)!)
        return NSData(data: UIImageJPEGRepresentation(thumbnail, 1.0)!) as Data

    }
}
