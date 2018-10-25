//
//  GroupEditView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol GroupEditViewDelegate: class {
    func editMemebersDidTap()
    func colorChangeDidTap()
    func nameDidChanged(isEmpty:Bool)
}

class GroupEditView: AbstractView {
    
    @IBOutlet weak var _textField: UITextField!
    @IBOutlet weak var _contatListView: ContactListView!
    @IBOutlet weak var _colorButton: UIButton!
    @IBOutlet weak var _editButton: UIButton!
    var delegate: GroupEditViewDelegate?
    
    fileprivate var _group:Group! {
        didSet {
            _textField.text = _group.name
            _textField.delegate = self
            _colorButton.backgroundColor = _group.color()
            _contatListView.setFriends(with: Array(_group.friends))
            _contatListView.setContacts(with: Array(_group.contacts))
            _editButton.isHidden = !_group.isEditable
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        super.setup()
        _contatListView._tableView.contentInset.bottom = _editButton.frame.height
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _textField.isFirstResponder {
            _textField.resignFirstResponder()
        }
    }
    
    func setGroup(with group:Group) {
        _group = group.copy() as? Group
    }

    func setGroupMembers(with friends:[Friend], and contacts: [Contact]) {
        _group.friends.removeAll()
        _group.friends.append(objectsIn: friends)
        _group.contacts.removeAll()
        _group.contacts.append(objectsIn: contacts)
        _contatListView.setFriends(with: Array(_group.friends))
        _contatListView.setContacts(with: Array(_group.contacts))

    }

    func setColorKey(with colorKey:Int) {
        _group.colorKey = colorKey
        _colorButton.backgroundColor = _group.color()
    }
    
    func editedGroup() -> Group {
        _group.name = _textField.text!
        return _group
    }
    
    @IBAction func _textFieldEditingDidChanged(_ sender: Any) {
        self.delegate?.nameDidChanged(isEmpty: _textField.text == nil || _textField.text!.isEmpty)
    }
    
    @IBAction func editDidTap(_ sender: Any) {
        delegate?.editMemebersDidTap()
    }
    
    @IBAction func colorDidTap(_ sender: Any) {
        delegate?.colorChangeDidTap()
    }
}

extension GroupEditView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _contatListView.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _contatListView.isUserInteractionEnabled = true
    }
}
