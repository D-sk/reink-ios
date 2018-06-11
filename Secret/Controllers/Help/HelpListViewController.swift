//
//  HelpListViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class HelpListViewController: AbstractViewController {
    @IBOutlet weak var helpListView: HelpListView!
    
    fileprivate var _selected: HelpBook!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.helpListView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentHelpBook" {
            guard let vc = segue.destination as? HelpBookViewController else {
                return
            }
            vc.helpBook = _selected
        }
    }
    

}

extension HelpListViewController: HelpListViewDelegate {
    func closeDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func helpDidTap(helpBook: HelpBook) {
        _selected = helpBook
        self.performSegue(withIdentifier: "presentHelpBook", sender: "self")
    }
}
