//
//  ColorEditView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol ColorEditViewDelegate: class {
    func colorChanged(colorKey:Int)
    func closeButtonDidTap()
}
class ColorEditView: AbstractView {

    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    weak var delegate: ColorEditViewDelegate?
    fileprivate var _colors = UIColor.Palette.all
    fileprivate var _current = UIColor.Palette.green
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        super.setup()
        self.configureTableView()
    }
    
    func configureTableView() {
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.registerCells(types: [ColorEditViewCell.self])
        _tableView.tableFooterView = UIView(frame:CGRect.zero)
        _tableView.reloadData()
        
    }

    func setColorPalette(with palette:UIColor.Palette) {
        _current = palette
        _tableView.reloadData()
    }
    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.delegate?.closeButtonDidTap()
    }
}

extension ColorEditView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = _tableView.dequeueCell(type: ColorEditViewCell.self, indexPath: indexPath)
        let p = _colors[indexPath.row]
        cell.configure(with: p.color(), title: p.title())
        
        if _current == p {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        } else  {
            cell.accessoryType = .none
        }

        return cell
    }
}

extension ColorEditView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ColorEditViewCell
        cell.accessoryType = .checkmark
        delegate?.colorChanged(colorKey: _colors[indexPath.row].rawValue)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ColorEditViewCell
        cell.accessoryType = .none
    }

}
