//
//  GroupListViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class GroupListViewController: AbstractViewController {

    @IBOutlet weak var _groupListView: GroupListView!
    
    fileprivate var _notificationToken: NotificationToken? = nil
    fileprivate var _groups: Results<Group>! {
        didSet{
            _notificationToken?.invalidate()
            
            _notificationToken = _groups.observe {(changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self._groupListView.setGroups(with: Array(self._groups))
                    break
                    
                case .update(_, _, let insertions, let modifications):
                    
                    if insertions.count > 0 || modifications.count > 0 {
                        self._groupListView.setGroups(with: Array(self._groups))
                    }
                    
                case .error(let error):
                    fatalError("\(error)")
                    
                }
            }
        }
        
    }
    fileprivate var _selectedGroup:Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _groupListView.delegate = self
        _groups = RealmManager.shared.groups()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if _groupListView.shouldSave {
            RealmManager.shared.saveGroups(with: _groupListView.editedGroups())
            
            if let vc = self.navigationController?.childViewControllers.first as? GroupFlipViewController {
                vc.refreshContents()
            }
        }
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
        if segue.identifier == "showGroupEdit" {
            if _selectedGroup != nil {
                (segue.destination as? GroupEditViewController)?.group = _selectedGroup!
            } else {
                let group = Group()
                group.displayOrder = _groups.count
                (segue.destination as? GroupEditViewController)?.group = group
            }
        }
    }
        
}

extension GroupListViewController: GroupLListViewDelegate {
    
    func groupDidTap(group: Group?) {
        _selectedGroup = group
        self.performSegue(withIdentifier: "showGroupEdit", sender: self)
    }
    
    func groupDidRemove(group: Group) {
        RealmManager.shared.deleteGroup(group)
    }
    
}
