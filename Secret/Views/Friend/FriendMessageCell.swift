//
//  FriendMessageCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/11/05.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class FriendMessageCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with message:Message) {
        self.dateLabel.text = message.receivedAt()
        self.textView.text = message.body
    }
}
