//
//  ContactListViewHeaderCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/30.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class ContactListViewHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
