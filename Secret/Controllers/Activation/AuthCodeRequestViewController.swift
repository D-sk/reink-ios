//
//  AuthCodeRequestViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/06.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class AuthCodeRequestViewController: AbstractViewController {

    @IBOutlet weak var authCodeRequestView: AuthCodeRequestView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.authCodeRequestView.delegate = self
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

extension AuthCodeRequestViewController: AuthCodeRequestViewDelegate {
    func requestButtonDidTap(email: String) {
        APIManager.shared.codeRequest(email:email, onSuccess: { [weak self] in
            guard let weakself = self else {
                return
            }
            weakself.performSegue(withIdentifier: "showActivation", sender: weakself)
        
        }, onFailure:{ [weak self] err in
            self?.presentAlertController(with: err)
        })
    }
}
