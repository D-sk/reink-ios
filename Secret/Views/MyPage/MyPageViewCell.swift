//
//  MyPageViewCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class MyPageViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var _thumbnail: UIImageView!
    @IBOutlet fileprivate weak var _thumbnailWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var _titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title:String) {
        _titleLabel.text = title
        _thumbnailWidth.constant = 0.0
        _thumbnail.isHidden = true
    }
    
    func configure(account: Account) {
        _titleLabel.text = account.name
        if let url = account.imageURL() {
            _thumbnail.af_setImage(withURL: url)
            _thumbnail.contentMode = .scaleAspectFill
        }
    }
}
