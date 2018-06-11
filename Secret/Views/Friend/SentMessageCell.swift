//
//  SentMessageCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/03.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class SentMessageCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with message:Message, isInverse:Bool=false) {
        bodyLabel.text = message.body
        dateLabel.text = message.receivedAt()
        if isInverse {
            bodyLabel.textColor = UIColor.Palette.offwhite.color()
            dateLabel.textColor = UIColor.Palette.gray.color()
        }
    }
}
