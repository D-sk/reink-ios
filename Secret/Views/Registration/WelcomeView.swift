//
//  WelcomeView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/09/20.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol WelcomeViewDelegate:class {
    func signupButtonDidTap()
    func loginButtonDidTap()
}
class WelcomeView: AbstractView {
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var delegate:WelcomeViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func signupButtonDidTap(_ sender: Any) {
        delegate?.signupButtonDidTap()
    }

    @IBAction func loginButtonDidTap(_ sender: Any) {
        delegate?.loginButtonDidTap()
    }

}
