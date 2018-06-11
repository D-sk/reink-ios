//
//  SwitchTab.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/04.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class SwitchTab: UIView {

    fileprivate var _titleLabel:UILabel = UILabel(frame: CGRect.zero)

    var title:String = "" {
        didSet{
            _titleLabel.text = title
            _titleLabel.textAlignment = .center
            _titleLabel.sizeToFit()
            if _titleLabel.frame.width < 48.0 {
                _titleLabel.frame.size.width = 48.0
            }
            self.frame.size.width = _titleLabel.frame.width+16.0
            _titleLabel.frame.origin.y = (self.frame.height - _titleLabel.frame.height)/2
            _titleLabel.frame.origin.x = (self.frame.width - _titleLabel.frame.width)/2
            self.setNeedsDisplay()
        }
    }
    
    var color:UIColor = UIColor.uiTint {
        didSet {
            if isSelected {
                _titleLabel.textColor = UIColor.white
                self.backgroundColor = self.color
            } else {
                _titleLabel.textColor = self.color
                self.backgroundColor = UIColor.clear
            }
            
        }
    }
    
    
    var isSelected:Bool = false {
        didSet{
            self.backgroundColor = UIColor.clear
            if isSelected{
                _titleLabel.textColor = UIColor.white
                self.backgroundColor = color
            }else{
                _titleLabel.textColor = color
                self.backgroundColor = UIColor.clear
            }
        }
        
    }
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        _titleLabel.textColor = color
        _titleLabel.frame.size.height = self.frame.height
        self.addSubview(_titleLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let radius = 8.0
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }

}
