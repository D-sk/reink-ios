//
//  LoadingView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/04/21.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class LoadingView: UIView {


    fileprivate let _indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var isAnimating:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.overlay
        _indicatorView.center = self.center
        self.addSubview(_indicatorView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating(){
        _indicatorView.startAnimating()
        self.isAnimating = true
    }
    
    func stopAnimating(){
        _indicatorView.stopAnimating()
        self.isAnimating = false
    }

}
