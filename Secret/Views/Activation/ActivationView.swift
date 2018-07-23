//
//  ActivationView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/01.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol ActivationViewDelegate: class {
    func authButtonDidTap(code:String)
    func closeDidTap()
    
}

class ActivationView: AbstractView {

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    weak var delegate: ActivationViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func setup() {
        super.setup()
        codeTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideKeyboard()
    }

    func hideKeyboard(){
        if codeTextField.isFirstResponder {
            codeTextField.resignFirstResponder()
        }
    }
    
    func setCloseButton(isModal:Bool) {
        self.closeButton.isHidden = !isModal
    }

    func isValidCode() -> Bool{
        if let txt = codeTextField.text {
            if txt.count == 0 {
                return false
            }
            return true
        }
        return false
    }
    
    func enableAuthButton(_ isEnabled:Bool){
        self.authButton.isUserInteractionEnabled = isEnabled
        if isEnabled {
            self.authButton.backgroundColor = UIColor.uiTint
        } else {
            self.authButton.backgroundColor = UIColor.uiLight
        }
    }

    @IBAction func authButtonDidTap(_ sender: Any) {
        delegate?.authButtonDidTap(code: codeTextField.text!)
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        delegate?.closeDidTap()
    }
}

extension ActivationView: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.enableAuthButton(self.isValidCode())
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
