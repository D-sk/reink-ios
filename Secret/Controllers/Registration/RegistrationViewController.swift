//
//  RegistrationViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/01/01.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class RegistrationViewController: AbstractViewController {

    @IBOutlet weak var registrationView: RegistrationView!
    var isLogin:Bool=false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.registrationView.delegate = self
        self.registrationView.isLogin = self.isLogin
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
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

extension RegistrationViewController: RegistrationViewDelegate {
    
    func registerDidTap(uname: String, pass: String) {
        if isLogin {
            
            APIManager.shared.login(uname: uname, pass: pass, onSuccess: { [weak self] userDict, token in
                
                let usr = User.object(from: userDict)
                RealmManager.shared.saveUser(with: usr)
                KeychainManager.shared.authToken = token
                
                self?.parent?.dismiss(animated: true, completion: nil)
                
            }, onFailure: { [weak self] err in
                self?.presentAlertController(with: err)
            })
            
        } else {
            
            APIManager.shared.register(uname: uname, pass: pass, onSuccess: { [weak self] dict in
                
                UserDefaultsManager.shared.isFirstLogin = true
                
                let usr = User.object(from: dict)
                RealmManager.shared.saveUser(with: usr)
                
                self?.parent?.dismiss(animated: true, completion: nil)
                
            }, onFailure: { [weak self] err in
                self?.presentAlertController(with: err)
            })

        }
    }
    
    func unameTextDidEdit(uname: String) {
        if isLogin {
            
        }
    }
}
