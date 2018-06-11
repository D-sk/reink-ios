//
//  GroupEditViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class GroupEditViewController: AbstractViewController {

    @IBOutlet weak var _groupEditView: GroupEditView!
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem?.isEnabled = !group.name.isEmpty
        _groupEditView.delegate = self
        _groupEditView.setGroup(with: self.group)
        
    }

    func setGroupMembers(with friends:[Friend], and contacts: [Contact]) {
        _groupEditView.setGroupMembers(with: friends, and: contacts)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setColorKey(with colorKey: Int) {
        _groupEditView.setColorKey(with: colorKey)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "presentColorEdit" {
            if let p = UIColor.Palette(rawValue: self.group.colorKey) {
                (segue.destination as! ColorEditViewController).palette = p
            }
        } else if segue.identifier == "showGroupMember" {
            (segue.destination as! GroupMemberViewController).group = _groupEditView.editedGroup()
        }
    }
    

    @IBAction func saveDidTap(_ sender: Any) {
        RealmManager.shared.saveGroup(with: _groupEditView.editedGroup())
        self.navigationController?.popViewController(animated: true)
    }
}

extension GroupEditViewController: GroupEditViewDelegate {
    
    func colorChangeDidTap() {
        performSegue(withIdentifier: "presentColorEdit", sender: self)
    }
    
    func editMemebersDidTap() {
        performSegue(withIdentifier: "showGroupMember", sender: self)
    }
    
    func nameDidChanged(isEmpty isEmtpy: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = !isEmtpy
    }
}
