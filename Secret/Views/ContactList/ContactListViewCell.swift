//
//  ContactListViewCell.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import Contacts

class ContactListViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var _thumbnail: UIImageView!
    @IBOutlet fileprivate weak var _titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        _thumbnail.layer.masksToBounds = true
        _thumbnail.layer.cornerRadius = _thumbnail.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func configure(contact:Contact){
        _titleLabel.text = contact.fullName()
        
        guard let img = contact.thumbnail() else {
            _thumbnail.image = #imageLiteral(resourceName: "ProfileThumbnail")
            return
        }

        _thumbnail.image = img

    }
    
    func configure(friend:Friend){
        _titleLabel.text = friend.account!.name

        guard let url = friend.account!.imageURL() else {
            _thumbnail.image = #imageLiteral(resourceName: "ProfileThumbnail")
            return
            
        }
        _thumbnail.af_setImage(withURL: url)
    }

}
