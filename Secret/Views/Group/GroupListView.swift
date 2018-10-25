//
//  GroupListView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol GroupLListViewDelegate: class {
    func groupDidTap(group:Group?)
    func groupDidRemove(group:Group)
    
}
class GroupListView: AbstractView {

    @IBOutlet weak var _tableView: UITableView!
    weak var delegate:GroupLListViewDelegate?
    fileprivate var _groups = [Group]()
    var shouldSave: Bool = false
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        super.setup()
        self.configureTable()
    }
    
    fileprivate func configureTable() {
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.isEditing = true
        _tableView.allowsSelectionDuringEditing = true
        _tableView.registerCells(types: [
            GroupListViewCell.self as UITableViewCell.Type,
            GroupAddCell.self as UITableViewCell.Type
            ])
        _tableView.tableFooterView = UIView(frame:CGRect.zero)
    }
    
    func setGroups(with groups:[Group]) {
        _groups = groups
        _tableView.reloadData()
    }
    
    func editedGroups() -> [Group] {
        return _groups
    }
    
}

extension GroupListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _groups.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == _groups.count {
            return tableView.dequeueCell(type: GroupAddCell.self, indexPath: indexPath)
        } else {
            let cell = tableView.dequeueCell(type: GroupListViewCell.self, indexPath: indexPath)
            cell.configure(_groups[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == _groups.count {
            return false
        }
        return _groups[indexPath.row].isEditable
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == _groups.count {
            return false
        }
        return _groups[indexPath.row].isEditable
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let grp = _groups[proposedDestinationIndexPath.row]
        if grp.isEditable {
            return proposedDestinationIndexPath
        }
        return sourceIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let grp = _groups[sourceIndexPath.row]
        _groups.remove(at: sourceIndexPath.row)
        _groups.insert(grp, at: destinationIndexPath.row)
        self.shouldSave = true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grp = self._groups[indexPath.row]
            self._groups.remove(at: indexPath.row)
            self._tableView.deleteRows(at: [indexPath], with: .fade)
            self.delegate?.groupDidRemove(group: grp)

        }
    }
    
    
}

extension GroupListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == _groups.count {
            self.delegate?.groupDidTap(group: nil)
        } else {
            self.delegate?.groupDidTap(group: _groups[indexPath.row])
        }
    }
}

