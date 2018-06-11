//
//  MyPageViewSettingsCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class MyPageViewSettingsCell: UITableViewCell {

    @IBOutlet fileprivate weak var _titleLabel: UILabel!
    @IBOutlet fileprivate weak var _switch: UISwitch!
    var switchValueChanged:((Bool)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title:String, isOn:Bool) {
        _titleLabel.text = title
        _switch.isOn = isOn
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        self.switchValueChanged?(_switch.isOn)
    }
}
