//
//  UserViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/06/16.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class UserViewController: AbstractViewController {
    
    @IBOutlet weak var userView: UserView!
    
    fileprivate var _notificationToken: NotificationToken? = nil
    
    fileprivate var _user:User! {
        didSet{
            _notificationToken?.invalidate()
            
            _notificationToken = _user.observe {change in
                switch change {
                case .change(_):
                    self.userView.setUser(self._user)
                case .error(let error):
                    fatalError("\(error)")
                case .deleted:
                    break
                    
                }
            }
        }
        
    }
    
    deinit {
        _notificationToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userView.delegate = self
        if let user = RealmManager.shared.user() {
            _user = user
            self.userView.setUser(_user)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showUserEditEmail" {
            (segue.destination as! UserEditViewController).editType = .email
        } else if segue.identifier == "showUserEditPassword" {
            (segue.destination as! UserEditViewController).editType = .password
        }
    }
    

}

extension UserViewController: UserViewDelgate {
    
    func emailDidTap() {
        self.performSegue(withIdentifier: "showUserEditEmail", sender: self)
    }
    
    func passwordDidTap() {
        self.performSegue(withIdentifier: "showUserEditPassword", sender: self)
    }
    
    func withdrawDidTap() {
        DispatchQueue.main.async {
            let ac = AlertManager.shared.alertController(.withdrawConfirmation, handler: {

                APIManager.shared.withdraw(onSuccess: {
                    
                    resetAll()
                    UIApplication.shared.keyWindow?.rootViewController = InitialViewController.instantiate()
                    
                    
                }, onFailure: {error in
                    self.presentAlertController(with: error)
                })

            }, cancelHandler: nil)
            
            self.present(ac, animated: true, completion: nil)
        }

    }
    
    func backDidTap() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
