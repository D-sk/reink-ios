//
//  LocalAuthViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import LocalAuthentication

class LocalAuthViewController: AbstractViewController {

    @IBOutlet weak var reAuthButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    fileprivate func auth() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "認証を行います", reply: { success, error in
            DispatchQueue.main.async {
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.reAuthButton.isHidden = false
                }
            }
        })
    }

    @IBAction func reAuthButtonDidTap(_ sender: Any) {
        self.reAuthButton.isHidden = true
        self.auth()
    }

}
