//
//  HistoryViewCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class HistoryViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var _thumbnail: UIImageView!
    @IBOutlet fileprivate weak var _titleLabel: UILabel!
    @IBOutlet fileprivate weak var _dateLabel: UILabel!
    @IBOutlet fileprivate weak var _badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func configure(friend:Friend) {
        _dateLabel.text = friend.receivedAtString()
        if let url = friend.account!.imageURL() {
            _thumbnail.af_setImage(withURL: url)
            _thumbnail.contentMode = .scaleAspectFill
        } else {
            _thumbnail.image = #imageLiteral(resourceName: "ProfileThumbnail")
            _thumbnail.contentMode = .scaleAspectFit
        }
        _titleLabel.text = friend.account!.name
        _badgeLabel.isHidden = friend.messageCount==0
        _badgeLabel.text = String(friend.messageCount)
    }

}
