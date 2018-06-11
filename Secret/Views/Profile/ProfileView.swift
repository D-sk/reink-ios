//
//  ProfileView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/09/24.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift


protocol ProfileViewDelegate: class {
    func cancelButtonDidTap()
    func saveButtonDidTap(account:Account)
    func thumbnailDidTap()
}

class ProfileView: AbstractView {

    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var _thumbnail: UIImageView!
    @IBOutlet weak var _idLabel: UILabel!
    @IBOutlet weak var _nameField: TextField!
    @IBOutlet weak var _cancelButton: UIButton!
    @IBOutlet weak var _saveButton: UIButton!
    @IBOutlet weak var _thumbnailButton: UIButton!
    
    weak var delegate: ProfileViewDelegate?
    fileprivate var _account:Account = Account()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func setup() {
        super.setup()
        _thumbnailButton.imageView?.contentMode = .scaleAspectFill
        _nameField.delegate = self
        self.configureTableView()
    }
    
    fileprivate func configureTableView(){
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.registerCells(types: [ProfileViewItemCell.self])
        _tableView.rowHeight = 48.0
        let v = UIView(frame: CGRect(x: 0, y: 0, width: _tableView.frame.width, height: 1))
        v.backgroundColor = UIColor.separator
        _tableView.tableFooterView = v
    }
    
    fileprivate func setThumbnail() {
        if let url = _account.imageURL() {
            _thumbnail.contentMode = .scaleAspectFill
            
            _thumbnail.af_setImage(withURL: url)
        } else {
            _thumbnail.contentMode = .bottom
        }
    }

    func setAccount(account:Account, isNew:Bool=false) {
        _cancelButton.isHidden = (account.id == 0)
        _account = account.copy() as! Account
        _idLabel.text = _account.uname
        _nameField.text = _account.name
        self.setThumbnail()
        self.enableSaveButton()
        _tableView.reloadData()
    }

    func setProfileImage(image: UIImage){
        _thumbnail.image = image        
    }
    
    
    func hideKeyboard(){
        _nameField.endEditing(true)
        for s in 0..<_tableView.numberOfSections {
            for r in 0..<_tableView.numberOfRows(inSection: s) {
                let at = IndexPath(row: r, section: s)
                let cell = _tableView.cellForRow(at: at) as? ProfileViewItemCell
                cell?.textField.endEditing(true)
            }
        }
    }


    func enableSaveButton() {
        _saveButton.isUserInteractionEnabled = (_nameField.text?.isEmpty == false)
        if _saveButton.isUserInteractionEnabled {
            _saveButton.setTitleColor(UIColor.uiTint, for: .normal)
        } else {
            _saveButton.setTitleColor(UIColor.uiLight, for: .normal)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _nameField.isFirstResponder {
            _nameField.resignFirstResponder()
        }
        
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        delegate?.cancelButtonDidTap()
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        self.hideKeyboard()
        delegate?.saveButtonDidTap(account: _account)
    }
    
    @IBAction func thumbnailButtonDidTap(_ sender: Any){
        delegate?.thumbnailDidTap()
    }
    
    @IBAction func nameFieldEditingChanged(_ sender: Any) {
        self.enableSaveButton()
    }

}

extension ProfileView:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: ProfileViewItemCell.self, indexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.configure(phone: _account.phone)
            cell.didValueChanged = { value in
                self._account.phone = value
            }
        case 1:
            cell.configure(email: _account.email)
            cell.didValueChanged = { value in
                self._account.email = value
            }
        default:
            break
        }
        return cell
    }
}

extension ProfileView:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ProfileView:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _nameField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        _account.name = _nameField.text!
    }
}
