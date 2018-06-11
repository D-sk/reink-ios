//
//  AuthCodeRequestView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/06.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol AuthCodeRequestViewDelegate {
    func requestButtonDidTap(email:String)
}

class AuthCodeRequestView: AbstractView {
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    var delegate: AuthCodeRequestViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func setup() {
        super.setup()
        self.emailTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideKeyboard()
    }
    
    func hideKeyboard(){
        if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
        }
    }
    
    func isValidEmail() -> Bool{
        if let txt = emailTextField.text {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return predicate.evaluate(with: txt)
        }
        return false
    }
    
    func enableRequestButton(_ isEnabled:Bool){
        requestButton.isUserInteractionEnabled = isEnabled
        if isEnabled {
            requestButton.backgroundColor = UIColor.uiTint
        } else {
            requestButton.backgroundColor = UIColor.uiLight
        }
    }

    @IBAction func requestButtonDidTap(_ sender: Any) {
        delegate?.requestButtonDidTap(email: emailTextField.text!)
    }
    
    
}

extension AuthCodeRequestView: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.enableRequestButton(self.isValidEmail())
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
