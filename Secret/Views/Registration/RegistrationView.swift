//
//  RegistrationView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/09/20.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol RegistrationViewDelegate: class {
    func unameTextDidEdit(uname:String)
    func registerDidTap(uname:String, pass:String)
}

class RegistrationView: AbstractView {

    @IBOutlet weak var unameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var wrongUnameLabel: UILabel!
    @IBOutlet weak var wrongPassLabel: UILabel!
    @IBOutlet weak var annotationTextView: UITextView!
    @IBOutlet weak var registerButton: UIButton!

    weak var delegate:RegistrationViewDelegate?
    var isLogin:Bool = false {
        didSet {
            annotationTextView.isHidden = isLogin
            if isLogin {
                registerButton.setTitle("ログイン", for: .normal)
            } else {
                registerButton.setTitle("登録", for: .normal)
            }
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup(){
        super.setup()
        self.unameTextField.delegate = self
        self.passTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideKeyboard()
    }
    
    func hideKeyboard(){
        if unameTextField.isFirstResponder {
            unameTextField.resignFirstResponder()
        }
        if passTextField.isFirstResponder {
            passTextField.resignFirstResponder()
        }
    }
    
    func isValidID() -> Bool{
        if let txt = unameTextField.text {
            if txt.count == 0 {
                wrongUnameLabel.text = "ユーザーネームを入力してください"
                return false
            } else if txt.count < 4 {
                wrongUnameLabel.text = "ユーザーネームは4文字以上です"
                return false
            } else if txt.isAllHankaku == false {
                wrongUnameLabel.text = "半角以外の文字が含まれています"
                return false
            }
            wrongUnameLabel.text = nil
            delegate?.unameTextDidEdit(uname: txt)
            return true
        } else {
            wrongUnameLabel.text = "ユーザーネームを入力してください"
            return false
        }
    }
    
    func isValidPass() -> Bool {
        if let txt = passTextField.text {
            if txt.count == 0 {
                wrongPassLabel.text = "パスワードを入力してください"
                return false
            } else if txt.count < 8 {
                wrongPassLabel.text = "パスワードは8文字以上です"
                return false
            } else if txt.isAllHankaku == false {
                wrongPassLabel.text = "半角以外の文字が含まれています"
                return false
            }
            wrongPassLabel.text = nil
            return true
        } else {
            wrongPassLabel.text = "パスワードを入力してください"
            return false
        }
    }
    

    func canRegister() -> Bool {
        return self.isValidID() && self.isValidPass()
    }
    
    func enableRegisterButton(_ isEnabled:Bool){
        self.registerButton.isUserInteractionEnabled = isEnabled
        if isEnabled {
            self.registerButton.backgroundColor = UIColor.uiTint
        } else {
            self.registerButton.backgroundColor = UIColor.uiLight
        }
    }
    
    @IBAction func registerButtonDidTap(_ sender: Any) {
        delegate?.registerDidTap(uname: unameTextField.text!, pass: passTextField.text!)
    }
}

extension RegistrationView:UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.enableRegisterButton(self.canRegister())
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
