//
//  UserView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/16.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol UserViewDelgate: class {
    func emailDidTap()
    func passwordDidTap()
    func withdrawDidTap()
    func backDidTap()
}

class UserView: AbstractView {

    
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var _backButton: UIButton!
    weak var delegate: UserViewDelgate?
    fileprivate var _user: User!
    
    enum Section {
        case email
        case password
        case withdraw
        
        static func all() -> [Section] {
            return [.email, .password, .withdraw]
        }
        
        func title() -> String {
            switch self {
            case .email: return NSLocalizedString("AccountSectionTitleEmail", comment: "AccountSectionTitle")
            case .password: return NSLocalizedString("AccountSectionTitlePassword", comment: "AccountSectionTitle")
            case .withdraw: return NSLocalizedString("AccountSectionTitleWithdraw", comment: "AccountSectionTitle")
            }
        }
        
        func comment() -> String {
            switch self {
            case .email: return NSLocalizedString("AccountSectionCommentEmail", comment: "AccountSectionComment")
            case .password: return NSLocalizedString("AccountSectionCommentPassword", comment: "AccountSectionComment")
            case .withdraw: return NSLocalizedString("AccountSectionCommentWithdraw", comment: "AccountSectionComment")
            }
        }
        
        func label() -> String {
            switch self {
            case .email: return NSLocalizedString("AccountSectionLabelEmail", comment: "AccountSectionLabel")
            case .password: return NSLocalizedString("AccountSectionLabelPassword", comment: "AccountSectionLabel")
            case .withdraw: return NSLocalizedString("AccountSectionLabelWithdraw", comment: "AccountSectionLabel")
            }
        }
    }

    fileprivate let _sections = Section.all()
    
    override func setup() {
        super.setup()
        
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.registerCell(type: UserViewCell.self)
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setUser(_ user:User) {
        _user = user
        _titleLabel.text = _user.uname
        _tableView.reloadData()
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.delegate?.backDidTap()
    }
    
}

extension UserView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _sections[section].title()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return _sections[section].comment()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: UserViewCell.self, indexPath: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        let sec = _sections[indexPath.section]
        
        switch sec {
        case .email:
            cell.textLabel?.text = _user.email
            cell.textLabel?.textColor = UIColor.Palette.black.color()
        case .password:
            cell.textLabel?.text = sec.label()
            cell.textLabel?.textColor = UIColor.Palette.black.color()
        case .withdraw:
            cell.textLabel?.text = sec.label()
            cell.textLabel?.textColor = UIColor.Palette.red.color()
        }
        return cell
    }
    
}

extension UserView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if _sections[section] == .withdraw {
            return 96.0
        }
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sec = _sections[indexPath.section]
        switch sec {
        case .email:
            self.delegate?.emailDidTap()
        case .password:
            self.delegate?.passwordDidTap()
        case .withdraw:
            self.delegate?.withdrawDidTap()
        }

    }
    
}
