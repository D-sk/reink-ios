//
//  HelpListView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol HelpListViewDelegate: class {
    func helpDidTap(helpBook: HelpBook)
    func closeDidTap()
}

class HelpListView: AbstractView {

    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _descLabel: UILabel!
    @IBOutlet weak var _showHelpBook1st: UIButton!
    @IBOutlet weak var _showHelpBook2nd: UIButton!
    @IBOutlet weak var _showHelpBook3rd: UIButton!
    
    var delegate: HelpListViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        super.setup()
        _titleLabel.text = NSLocalizedString("HelpListTitle", comment: "HelpList")
        _descLabel.text = NSLocalizedString("HelpListDesc", comment: "HelpList")
        _showHelpBook1st.setTitle(HelpBook.all[_showHelpBook1st.tag-1].title(), for: .normal)
        _showHelpBook2nd.setTitle(HelpBook.all[_showHelpBook2nd.tag-1].title(), for: .normal)
        _showHelpBook3rd.setTitle(HelpBook.all[_showHelpBook3rd.tag-1].title(), for: .normal)
        
    }

    @IBAction func closeDidTap(_ sender: Any) {
        self.delegate?.closeDidTap()
    }
    
    @IBAction func showHelpBookDidTap(_ sender: Any) {
        guard let btn = sender as? UIButton else {
            return
        }
        let idx = btn.tag-1
        if idx < 0 || idx >= HelpBook.all.count {
            return
        }
        self.delegate?.helpDidTap(helpBook: HelpBook.all[idx])
    }
}
