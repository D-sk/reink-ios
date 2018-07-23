//
//  ContactListView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol ContactListViewDelegate:class {
    func friendDidTap(friend:Friend)
    func contactDidTap(contact:Contact)
}

class ContactListView: AbstractView {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate:ContactListViewDelegate?
    var color:UIColor?
    fileprivate var _sections:[String] = [String]()
    fileprivate var _friends:[Friend] = [Friend]()
    fileprivate var _contacts:[String:[Contact]] = [String:[Contact]]()
    
    // Group Member Edit
    var isEdit:Bool = false
    fileprivate var _selectedFriends:[Friend] = [Friend]()
    fileprivate var _selectedContacts:[Contact] = [Contact]()

    private let INDEXES = [
        "あ", "か", "さ", "た", "な", "は", "ま", "や", "ら", "わ",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
        "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
        "W", "X", "Y", "Z", "#"
    ]
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func setup() {
        super.setup()
        _sections = INDEXES
        _contacts = _sections.reduce([String: [Contact]]()) {(dict, sec) in
            var ret = dict
            ret[sec] = [Contact]()
            return ret
        }

        self.configureTableView()
    }


    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCells(types: [
            ContactListViewCell.self,
            ContactListViewHeaderCell.self,
            HistoryViewCell.self
            ])
        tableView.sectionIndexColor = UIColor.Palette.black.color()
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame:CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
    }
    
    
    func setFriends(with friends:Array<Friend>){

        if friends.count > 0 && _sections.index(of: "★") == nil {
            _sections.insert("★", at: 0)
        }
        _friends = friends
        tableView.reloadData()
    }

    func setContacts(with contacts:Array<Contact>){
        _contacts = _sections.reduce([String: [Contact]]()) {(dict, sec) in
            var ret = dict
            ret[sec] = [Contact]()
            return ret
        }

        for c in contacts {
            let char = c.phonetic.first!
            let key = sectionTitle(String(char))
            _contacts[key]?.append(c)
        }
        tableView.reloadData()
    }

    fileprivate func isEmpty() -> Bool {
        let cnt = _contacts.reduce(0){(num, c) -> Int in
            num + c.value.count
        }
        return (_friends.count == 0 && cnt == 0)
    }
    
    func setSelectedFriends(with friends: [Friend], and contacts: [Contact]) {
        _selectedFriends.append(contentsOf: friends)
        _selectedContacts.append(contentsOf: contacts)
        self.tableView.reloadData()
    }

    func sectionTitle(_ string:String) -> String {
        let uc = string.unicodeScalars.first!.value
        if ( uc >= 0x3041 && uc <= 0x304A) {
            return "あ"
        } else if (uc >= 0x304B && uc <= 0x3054) {
            return "か"
        } else if (uc >= 0x3055 && uc <= 0x305E) {
            return "さ"
        } else if (uc >= 0x305F && uc <= 0x3069) {
            return "た"
        } else if (uc >= 0x306A && uc <= 0x306E) {
            return "な"
        } else if (uc >= 0x306F && uc <= 0x307D) {
            return "は"
        } else if (uc >= 0x307E && uc <= 0x3082) {
            return "ま"
        } else if (uc >= 0x3083 && uc <= 0x3088) {
            return "や"
        } else if (uc >= 0x3089 && uc <= 0x308D) {
            return "ら"
        } else if (uc >= 0x308F && uc <= 0x3093) {
            return "わ"
        }
        return string
    }
    
    func selectedFriends() -> [Friend] {
        return _selectedFriends
    }
    
    func selectedContacts() -> [Contact] {
        return _selectedContacts
    }
    
    
}

extension ContactListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && _friends.count > 0 {
            return _friends.count
        } else {
            return _contacts[_sections[section]]!.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && _friends.count > 0 {
            
            let f = _friends[indexPath.row]
            
            if self.isEdit {
                let cell = tableView.dequeueCell(type: ContactListViewCell.self, indexPath: indexPath)
                cell.configure(friend: f)
                if _selectedFriends.index(of: f) == nil {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .checkmark
                }
                return cell
            
            } else {
                let cell = tableView.dequeueCell(type: HistoryViewCell.self, indexPath: indexPath)
                cell.configure(friend: f)
                return cell
            }

        }else {
            let cell = tableView.dequeueCell(type: ContactListViewCell.self, indexPath: indexPath)
            let section = _sections[indexPath.section]
            let c = _contacts[section]![indexPath.row]
            cell.configure(contact: c)
            if self.isEdit {
                if _selectedContacts.index(of: c) == nil {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .checkmark
                }
            }
            return cell
        }
        
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if self.isEmpty() {
            return nil
        }
        return _sections
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && _friends.count > 0 {
        
            return 30.0
        
        } else {

            if _contacts[_sections[section]]!.count == 0 {
                return 0
            }

            return 30.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueCell(type: ContactListViewHeaderCell.self)
        if section == 0 && _friends.count > 0 {
            cell.titleLabel.text = NSLocalizedString("HeaderTitleFriend", comment: "HeaderTitle")
            cell.effectView.backgroundColor = self.color
        } else {
            cell.titleLabel.text = _sections[section]
            cell.effectView.backgroundColor = UIColor.clear
        }
        
        return cell.contentView
    }
}

extension ContactListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isEdit {
            return 48.0
        } else {
            if indexPath.section == 0 && _friends.count > 0 {
                return 64.0
            }
            return 48.0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isEdit {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }

            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
            
            if indexPath.section == 0 && _friends.count > 0 {
                let f = _friends[indexPath.row]
                if let idx = _selectedFriends.index(of: f) {
                    _selectedFriends.remove(at: idx)
                } else {
                    _selectedFriends.append(f)
                }
                
            }else {
                let section = _sections[indexPath.section]
                let c = _contacts[section]![indexPath.row]
                if let idx = _selectedContacts.index(of: c) {
                    _selectedContacts.remove(at: idx)
                } else {
                    _selectedContacts.append(c)
                }
            }

        } else {
            if indexPath.section == 0 && _friends.count > 0{
                let f = _friends[indexPath.row]
                delegate?.friendDidTap(friend: f)
            } else {
                let section = _sections[indexPath.section]
                let c = _contacts[section]![indexPath.row]
                delegate?.contactDidTap(contact: c)
            }
        }
    }
}

