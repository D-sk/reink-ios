//
//  UesrEditViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/17.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class UserEditViewController: AbstractViewController {

    @IBOutlet weak var userEditView: UserEditView!
    var editType:UserEditView.EditType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userEditView.delegate = self
        self.userEditView.setType(editType: editType)
        
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

extension UserEditViewController: UserEditViewDelegate {
    func updateDidTap(target:String, password:String) {
        switch self.editType {
        case .email:

            APIManager.shared.updateEmail(email: target, password: password, onSuccess: {
                
                let vc = ActivationViewController.instantiate()
                self.present(vc, animated: true, completion: {
                    _ = self.navigationController?.popViewController(animated: true)
                })

            }, onFailure: { error in
                self.presentAlertController(with: error)
            })
        
        case .password:
        
            APIManager.shared.updatePassword(current: password, new: target, onSuccess: { token in
        
                KeychainManager.shared.authToken = token
                
                let ac = AlertManager.shared.alertController(.passwordChanged, handler: {
                    _ = self.navigationController?.popViewController(animated: true)
                }, cancelHandler: nil)
                self.present(ac, animated: true, completion: nil)
                
            }, onFailure: { error in
                self.presentAlertController(with: error)
            })
        
        default:
            break
        }
    }
    
    func closeDidTap() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
