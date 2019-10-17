//
//  AbstractViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class AbstractViewController: UIViewController {

    var loadingView:LoadingView!
    
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

    func isModal()->Bool{
        return self.navigationController == nil
    }

    func presentInternalError() {
        let ac = AlertManager.shared.alertController(.internalError, handler: nil, cancelHandler: nil)
        self.present(ac, animated: true, completion: nil)
    }
    
    func presentAlertController(with err: NSError) {
        let ac = AlertManager.shared.alertController(err)
        self.present(ac, animated: true, completion: nil)
    }
    
    func addLoadingView(_ frame:CGRect){
        if self.loadingView == nil {
            self.loadingView = LoadingView(frame:frame)
        }
        
        if self.loadingView.isAnimating == false {
            if let nvc = self.navigationController, frame == UIScreen.main.bounds {
                nvc.view.addSubview(self.loadingView)
            } else {
                self.view.addSubview(self.loadingView)
            }
            self.loadingView.startAnimating()
        }
        
    }
    
    func insertLoadingView(_ frame:CGRect, aboveSubView:UIView){
        if self.loadingView == nil {
            self.loadingView = LoadingView(frame:frame)
            self.view.insertSubview(self.loadingView, aboveSubview: aboveSubView)
        }
        self.loadingView.startAnimating()
    }
    
    func removeLoadingView(){
        if self.loadingView != nil {
            self.loadingView.stopAnimating()
            self.loadingView.removeFromSuperview()
            self.loadingView = nil
        }
    }

}

extension AbstractViewController {
    @objc func keyboardWillShow(_ notification:Notification){
        if let userInfo = (notification as NSNotification).userInfo{
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.size.height)
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
            UIView.animate(withDuration: duration, animations: {
                self.view.transform = transform
            }, completion: nil)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification){
        if let userInfo = (notification as NSNotification).userInfo{
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
            UIView.animate(withDuration: duration, animations: {
                self.view.transform = .identity
            }, completion: nil)
        }
    }
}
