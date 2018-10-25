//
//  MyPageView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol MyPageViewDelegate:class {
    func accountDidTap()
    func qrCodeDidTap()
    func helpDidTap(help: HelpBook)
    func informationDidTap(url:URL)
    func passcodeSettingsValueChanged(isOn:Bool)
    func logoutDidTap()
}

class MyPageView: AbstractView {

    @IBOutlet fileprivate weak var _tableView: UITableView!
    @IBOutlet fileprivate weak var _tableViewTrailing: NSLayoutConstraint!
    @IBOutlet fileprivate weak var _tableViewLeading: NSLayoutConstraint!
    @IBOutlet fileprivate weak var _backgroundView: UIView!
    
    fileprivate enum Menu:String {
        case account = "Account"
        case settings = "Settings"
        case help = "Help"
        case information = "Inforimation"
        case logout = "Logout"
        
        public static let all: [Menu] = [
            .account,
            .settings,
            .help,
            .information,
            .logout
        ]

        func title() -> String {
            let comment = "MenuTitle"
            let key = comment + self.rawValue
            return NSLocalizedString(key, comment: comment)
        }
    }
    
    fileprivate enum Information:String {
        case terms = "Terms"
        case privacy = "Privacy"
        
        public static let all: [Information] = [
            .terms,
            .privacy,
        ]

        func title() -> String {
            let comment = "InformationTitle"
            let key = comment + self.rawValue
            return NSLocalizedString(key, comment: comment)
        }
        
        func url() -> URL {
            switch self {
            case .terms: return Consts.termsURL
            case .privacy: return Consts.privacyURL
            }
        }
    }

    fileprivate enum Settings: String {
        case passcode = "Passcode"
        
        public static let all: [Settings] = [
            .passcode
        ]
        
        func title() -> String {
            let comment = "SettingsTitle"
            var key = comment + self.rawValue
            switch self {
            case .passcode:
                if canUseFaceID() {
                    key = key + "Face"
                } else {
                    key = key + "Touch"
                }
            }
            return NSLocalizedString(key, comment: comment)
        }
        
    }

    fileprivate var _account:Account?
    fileprivate var _passCode:Bool = false
    
    weak var delegate:MyPageViewDelegate?
    
    override func setup() {
        super.setup()
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.registerCells(types: [
            MyPageViewCell.self as UITableViewCell.Type,
            MyPageViewSettingsCell.self as UITableViewCell.Type
            ])
    }
    
    func setAccount(_ acc:Account?) {
        _account = acc
        _tableView.reloadData()
    }
    
    func setPasscodeSettings(_ isOn: Bool) {
        _passCode = isOn
    }
    
    func open(){
        _tableViewLeading.constant = 0
        _tableViewTrailing.constant = 68
        _backgroundView.alpha = 1
    }
    
    func close(){
        let width = UIScreen.main.bounds.width
        _tableViewLeading.constant = -(width - 48)
        _tableViewTrailing.constant = width
        _backgroundView.alpha = 0
    }

}

extension MyPageView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Menu.all[indexPath.section] {
        case .account:
            switch indexPath.row {
            case 0:
                self.delegate?.accountDidTap()
            case 1:
                self.delegate?.qrCodeDidTap()
            default:
                break
            }
            
        case .help:
            self.delegate?.helpDidTap(help: HelpBook.all[indexPath.row])
        case .information:
            self.delegate?.informationDidTap(url: Information.all[indexPath.row].url())
        case .settings:
            break
        case .logout:
            self.delegate?.logoutDidTap()
        }
    }
}

extension MyPageView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Menu.all.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Menu.all[section].title()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Menu.all[section] {
        case .account:
            if _account == nil {
                return 0
            }
            return 2
        case .help:
            return HelpBook.all.count
        case .information:
            return Information.all.count
        case .logout:
            return 1
        case .settings:
            return Settings.all.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sec = Menu.all[indexPath.section]
        switch sec {
        case .account:
            let cell = _tableView.dequeueCell(type: MyPageViewCell.self, indexPath: indexPath)
            switch indexPath.row {
            case 0:
                cell.configure(account:_account!)
            case 1:
                cell.configure(title: NSLocalizedString("QRCodeTitle", comment: "QRCode"))
            case 2:
                let title = NSLocalizedString("SubscribedPlan", comment: "SubscribedPlan") //+ StoreManager.shared.productName(by: _account!.isSubscribed)
                cell.configure(title: title)
            default:
                break
            }
            return cell
            
        case .help:
            let cell = _tableView.dequeueCell(type: MyPageViewCell.self, indexPath: indexPath)
            cell.configure(title: HelpBook.all[indexPath.row].title())
            return cell

        case .information:
            let cell = _tableView.dequeueCell(type: MyPageViewCell.self, indexPath: indexPath)
            cell.configure(title: Information.all[indexPath.row].title())
            return cell
        
        case .logout:
            let cell = _tableView.dequeueCell(type: MyPageViewCell.self, indexPath: indexPath)
            cell.configure(title: sec.title())
            return cell

        case .settings:
            let cell = _tableView.dequeueCell(type: MyPageViewSettingsCell.self, indexPath: indexPath)
            cell.configure(title:Settings.all[indexPath.row].title(), isOn:_passCode)
            cell.switchValueChanged = { isOn in
                self.delegate?.passcodeSettingsValueChanged(isOn: isOn)
            }
            return cell
        }
    }
    
}
