//
//  GroupListViewCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class GroupListViewCell: UITableViewCell {

    @IBOutlet weak var _colorView: UIView!
    @IBOutlet weak var _titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ group:Group) {
        _colorView.backgroundColor = group.color()
        _titleLabel.text = group.name
    }
    
}
