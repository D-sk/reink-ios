//
//  ContactListViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class ContactListViewController: AbstractViewController {

    @IBOutlet var contactListView: ContactListView!
    fileprivate var _selectedContact:Contact!
    fileprivate var _selectedFriend:Friend!
    var touchEnded:(()->Void)?
    
    var group: Group? {
        didSet {
            guard let group = self.group else {
                self.contactListView.color = nil
                return
            }
            self.friends = Array(group.friends)
            self.contacts = Array(group.contacts)
            self.contactListView.color = UIColor.Palette(rawValue: group.colorKey+10)?.color()            
        }
    }
    
    var friends: Array<Friend>?{
        didSet{
            guard let friends = self.friends else {
                self.contactListView.setFriends(with: [Friend]())
                return
            }
            self.contactListView.setFriends(with: friends)
        }
    }

    var contacts: Array<Contact>?{
        didSet{
            guard let contacts = self.contacts else {
                self.contactListView.setContacts(with: [Contact]())
                return
            }
            self.contactListView.setContacts(with: contacts)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.contactListView.delegate = self
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchEnded?()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "presentFriend" {
            (segue.destination as! FriendViewController).friend = _selectedFriend
        } else if segue.identifier == "presentContact" {
            (segue.destination as! ContactViewController).contact = _selectedContact
        }
    }


}

extension ContactListViewController: ContactListViewDelegate{
    func contactDidTap(contact: Contact) {
        _selectedContact = contact
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "presentContact", sender: self)
        }
    }
    
    func friendDidTap(friend: Friend) {
        _selectedFriend = friend
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "presentFriend", sender: self)
        }
    }
}
