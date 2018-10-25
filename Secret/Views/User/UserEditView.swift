//
//  UserEditView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/16.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol UserEditViewDelegate: class {
    func updateDidTap(target:String, password:String)
    func closeDidTap()
}

class UserEditView: AbstractView {

    enum EditType: String {
        case email = "Email"
        case password = "Password"
        
        func title(at index:Int) -> String {
            let com = "EditTypeTitle"
            let key = com + self.rawValue + index.description
            return NSLocalizedString(key, comment: com)
        }

        func placeholder(at index:Int) -> String {
            let com = "EditTypePlaceholder"
            let key = com + self.rawValue + index.description
            return NSLocalizedString(key, comment: com)
        }
    }
    
    weak var delegate: UserEditViewDelegate?
    
    @IBOutlet weak var _closeButton: UIButton!
    @IBOutlet weak var _inputLabelFirst: UILabel!
    @IBOutlet weak var _inputFieldFirst: UITextField!
    @IBOutlet weak var _inputCommentFirst: UILabel!
    
    @IBOutlet weak var _inputLabelSecond: UILabel!
    @IBOutlet weak var _inputFieldSecond: UITextField!
    @IBOutlet weak var _inputCommentSecond: UILabel!

    @IBOutlet weak var _updateButton: UIButton!

    fileprivate var _editType: EditType = .email {
        didSet{
            
            _inputLabelFirst.text = _editType.title(at: 1)
            _inputFieldFirst.placeholder = _editType.placeholder(at: 1)
            _inputLabelSecond.text = _editType.title(at: 2)
            _inputFieldSecond.placeholder = _editType.placeholder(at: 2)

            if _editType == .password {
                _inputFieldFirst.isSecureTextEntry = true
            }
            _inputFieldSecond.isSecureTextEntry = true            
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
        _inputFieldFirst.delegate = self
        _inputFieldSecond.delegate = self
    }

    func setType(editType: EditType) {
        _editType = editType
    }
    
    fileprivate func canUpdate() -> Bool {
        
        guard let first = _inputFieldFirst.text else {
            _inputCommentFirst.text = nil
            return false
        }
        
        if first.count == 0 {
            _inputCommentFirst.text = nil
            return false
        }
        
        guard let second = _inputFieldSecond.text else {
            _inputCommentSecond.text = nil
            return false
        }
        
        if second.count == 0 {
            _inputCommentFirst.text = nil
            return false
        }
        
        switch _editType {
        case .email:
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if predicate.evaluate(with: first) == false {
                _inputCommentFirst.text = Annotation.notEmail.message()
                return false
            }
        case .password:
            if second.isAllHankaku == false {
                _inputCommentSecond.text = Annotation.notHankaku.message()
                return false
            } else if second.count < 8 {
                _inputCommentSecond.text = Annotation.shortPassowrd.message()
                return false
            }
        }
        
        _inputCommentFirst = nil
        _inputCommentSecond = nil
        return true
    }
    
    fileprivate func enableUpdateButton(_ isEnabled:Bool){
        _updateButton.isUserInteractionEnabled = isEnabled
        if isEnabled {
            _updateButton.backgroundColor = UIColor.uiTint
        } else {
            _updateButton.backgroundColor = UIColor.uiLight
        }
    }


    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.delegate?.closeDidTap()
    }
    
    @IBAction func updateButtonDidTap(_ sender: Any) {
        
        switch _editType {
        case .email:
            self.delegate?.updateDidTap(target:_inputFieldFirst.text!, password: _inputFieldSecond.text!)
        case .password:
            self.delegate?.updateDidTap(target:_inputFieldSecond.text!, password: _inputFieldFirst.text!)
        }
        
    }
}

extension UserEditView: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.enableUpdateButton(self.canUpdate())
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

