//
//  ProfileViewItemCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/09/23.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Contacts

class ProfileViewItemCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var textField: TextField!
    @IBOutlet weak var subLabelHeightConstraint: NSLayoutConstraint!
    private var isPhoneNumber:Bool!
    var didValueChanged:((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(phone: String?){
        textField.placeholder = "電話番号"
        textField.text = phone
        textField.keyboardType = .phonePad
        textField.tintColor = UIColor.uiTint
        icon.image = UIImage(named: "ProfilePhone")?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = UIColor.uiTint
        isPhoneNumber = true
    }
    
    func configure(email: String?){
        textField.placeholder = "メールアドレス"
        textField.text = email
        textField.keyboardType = .emailAddress
        textField.tintColor = UIColor.Palette.purple.color()
        icon.image = UIImage(named: "ProfileMail")?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = UIColor.Palette.purple.color()
        isPhoneNumber = false
    }
    
    @IBAction func textFieldEditingDidEnd(_ sender: Any) {
        if let tx = textField.text{
            didValueChanged?(tx)
        }
    }
    
}

extension ProfileViewItemCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
