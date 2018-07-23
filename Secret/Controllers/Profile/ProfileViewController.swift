//
//  ProfileViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/30.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileViewController: AbstractViewController {

    @IBOutlet weak var profileView: ProfileView!
    fileprivate var _newThumbnail:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.profileView.delegate = self
        if let usr = RealmManager.shared.user() {
        
            self.profileView.setUserAccount(with: usr)
        
        } else {
            
            let ac = AlertManager.shared.alertController(.authError, handler: nil, cancelHandler: nil)
            self.present(ac, animated: true, completion: nil)
            if self.isModal() {
                self.dismiss(animated: true, completion: nil)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
            
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

extension ProfileViewController: ProfileViewDelegate {
    func cancelButtonDidTap(){
        if self.isModal() {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func saveButtonDidTap(account:Account){
        if account.id == 0 {
            account.create(with: _newThumbnail, onSuccess: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            
            }, onFailure: { [weak self] err in
                self?.presentAlertController(with: err)
                
            })

        } else {
            
            account.update(with: _newThumbnail, onSuccess: { [weak self] in
                
                _ = self?.navigationController?.popViewController(animated: true)
            
            }, onFailure: { [weak self] err in
                self?.presentAlertController(with: err)
                
            })
        }
        
    }
    
    func thumbnailDidTap() {
        self.profileView.hideKeyboard()
        PLManager.shared.requestLibraryAccess(onGrant: {
            let completion:(_ completed:Bool, _ image:UIImage?, _ fileName:String?)->Void = {completed, image, fileName in
                if completed && image != nil && fileName != nil{
                    self._newThumbnail = image!
                    self.profileView.setProfileImage(image: self._newThumbnail!)
                }
            }
            let ac = AlertManager.shared.thumbnailChangeAlertController(
                photoAction: {
                    if let vc = PLManager.shared.cameraController(completion: completion){
                        self.present(vc, animated: true, completion: nil)
                    }else{
                        let ac = AlertManager.shared.alertController(.photoAccessGrant, handler: nil, cancelHandler: nil)
                        self.present(ac, animated: true, completion: nil)
                    }
            },libraryAction: {
                if let vc = PLManager.shared.libraryController(completion: completion){
                    self.present(vc, animated: true, completion: nil)
                }else{
                    let ac = AlertManager.shared.alertController(.photoAccessGrant, handler: nil, cancelHandler: nil)
                    self.present(ac, animated: true, completion: nil)
                }
            })
            self.present(ac, animated: true, completion: nil)
        }, onDeny: {
            
        })
    }
    
    func idDidTap() {
        self.performSegue(withIdentifier: "showAccount", sender: self)
    }

}
