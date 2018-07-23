//
//  HelpBookViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/11.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit



class HelpBookViewController: AbstractViewController {
    
    @IBOutlet fileprivate weak var _helpBookView: HelpBookView!
    var helpBook:HelpBook!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _helpBookView.delegate = self
        _helpBookView.setButton(isModal: self.isModal())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _helpBookView.setBook(as: helpBook)
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

}

extension HelpBookViewController: HelpBookViewDelegate {
    
    func backDidTap(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func closeDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
