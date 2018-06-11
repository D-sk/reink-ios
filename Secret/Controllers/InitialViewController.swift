//
//  InitialViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/09/20.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class InitialViewController: AbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaultsManager.shared.isFirstOpen {
            resetAll()
            UserDefaultsManager.shared.isFirstOpen = false
        }
        
        if KeychainManager.shared.uname.isEmpty {
            self.performSegue(withIdentifier: "presentWelcome", sender: self)
        
        } else if KeychainManager.shared.authToken.isEmpty {
            self.performSegue(withIdentifier: "presentActivation", sender: self)
        
        } else if RealmManager.shared.myAccount() == nil {
            
            let pvc = ProfileViewController.instantiate()
            self.present(pvc, animated: true, completion: nil)
        
        } else {
            CNContactManager.shared.sync()
            self.performSegue(withIdentifier: "presentTimeline", sender: self)
        
        }
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
