//
//  WelcomeViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/11.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class WelcomeViewController: AbstractViewController {

    @IBOutlet weak var welcomeView: WelcomeView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        welcomeView.delegate = self
        
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

extension WelcomeViewController: WelcomeViewDelegate {
    
    func signupButtonDidTap() {
        self.performSegue(withIdentifier: "showRegistration", sender: self)
    }
    
    func loginButtonDidTap() {
        let rvc = RegistrationViewController.instantiate()
        rvc.isLogin = true
        self.navigationController?.show(rvc, sender: nil)
    }
    
}
