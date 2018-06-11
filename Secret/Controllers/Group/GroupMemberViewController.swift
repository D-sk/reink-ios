//
//  GroupMemberViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/21.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class GroupMemberViewController: AbstractViewController {

    @IBOutlet weak var _searchField: UITextField!
    @IBOutlet weak var _contactListView: ContactListView!
    
    var group:Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _contactListView.isEdit = true

        guard let ga = RealmManager.shared.groupAll() else {
            return
        }
        _contactListView.setFriends(with: Array(ga.friends))
        _contactListView.setContacts(with: Array(ga.contacts))

        guard let group = self.group else {
            return
        }
        
        var selectedFriends = [Friend]()
        var selectedContacts = [Contact]()
        for f in ga.friends {
            for selected in group.friends {
                if f.id == selected.id {
                    selectedFriends.append(f)
                }
            }
        }
        
        for c in ga.contacts {
            for selected in group.contacts {
                if c.identifier == selected.identifier {
                    selectedContacts.append(c)
                }
            }
        }
        
        _contactListView.setSelectedFriends(with: selectedFriends, and: selectedContacts)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let vc = self.navigationController?.topViewController as? GroupEditViewController else {
            return
            
        }
        vc.setGroupMembers(with: _contactListView.selectedFriends(), and: _contactListView.selectedContacts())

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func searchFieldEditingDidCahnged(_ sender: Any) {
        if _searchField.markedTextRange != nil {
            return
        }
        
        guard let txt = _searchField.text else {
            return
        }
        _contactListView.setFriends(with: Array(RealmManager.shared.friends(with: txt)))
        _contactListView.setContacts(with: Array(RealmManager.shared.contacts(with: txt)))
    }
    
}
