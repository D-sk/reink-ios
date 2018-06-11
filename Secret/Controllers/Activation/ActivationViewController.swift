//
//  ActivationViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/01.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class ActivationViewController: AbstractViewController {

    @IBOutlet weak var activationView: ActivationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.activationView.delegate = self
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

extension ActivationViewController: ActivationViewDelegate {
    func authButtonDidTap(code: String) {
        APIManager.shared.activate(code: code, onSuccess: { [weak self] authToken in
            
            KeychainManager.shared.authToken = authToken
            self?.dismiss(animated: true, completion: nil)
        
        }, onFailure: { [weak self] err in
            self?.presentAlertController(with: err)
            
        })
    }
}
