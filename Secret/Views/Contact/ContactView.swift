//
//  ContactView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol ContactViewDelegate: class {
    func phoneDidTap()
    func mailDidTap()
    func closeDidTap()
}

class ContactView: AbstractView {

    @IBOutlet fileprivate weak var _thumbnail: UIImageView!
    @IBOutlet fileprivate weak var _name: UILabel!
    @IBOutlet fileprivate weak var _phoneButton: UIButton!
    @IBOutlet fileprivate weak var _mailButton: UIButton!
    @IBOutlet fileprivate weak var _closeButton: UIButton!

    weak var delegate: ContactViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        super.setup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.closeDidTap()
    }
    
    @IBAction func phoneButtonDidTap(_ sender: Any) {
        delegate?.phoneDidTap()
    }
    
    @IBAction func mailButtonDidTap(_ sender: Any) {
        delegate?.mailDidTap()
    }
    @IBAction func closeButtonDidTap(_ sender: Any) {
        delegate?.closeDidTap()
    }
    
    func setContact(_ contact:Contact){
        _name.text = contact.fullName()
        if let img = contact.thumbnail() {
            _thumbnail.image = img
        }
    }
}
