//
//  FriendViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/11/05.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import MessageUI

class FriendViewController: AbstractViewController {

    @IBOutlet weak var friendView: FriendView!
    let transition:OverlayTransition = OverlayTransition()
    var friend:Friend!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transitioningDelegate = transition
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.friendView.delegate = self
        self.friendView.setFriend(friend: friend)
        
        if self.needsSubscribed() {
            self.friendView.showNotSubscribedMessage()
        } else {
            self.messages()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        if segue.identifier == "showProductFromFriend" {
            (segue.destination as! ProductViewController).product = StoreManager.shared.basicProduct()!
        }
    }
    
    
    func messages(){
        self.friendView.hideNotSubscribeMessage()
        Message.list(with: self.friend, onSuccess: { [weak self] messages in
            self?.friendView.setInbox(with: messages)
            
        }, onFailure: { [weak self] err in
            self?.presentAlertController(with: err)
        })
    }

    fileprivate func phoneCall(digits:String) {
        if let url = URL(string: "tel://" + digits) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
        }
    }
    
    fileprivate func openMailCompose(toValue:String){
        let vc = MFMailComposeViewController()
        vc.setToRecipients([toValue])
        vc.mailComposeDelegate = self
        self.present(vc, animated: true, completion: nil)
    }

    fileprivate func needsSubscribed() -> Bool {
        guard let me = RealmManager.shared.myAccount() else {
            return false
        }
        return me.isSubscribed == false && StoreManager.shared.basicProduct() != nil
    }
    
    fileprivate func showSubscriptionIfNeeded() {
        if self.needsSubscribed() {
            self.performSegue(withIdentifier: "showProductFromFriend", sender: self)
        }
    }
}

extension FriendViewController: FriendViewDelegate {
    
    func closeDidTap(messageCount:Int) {
        RealmManager.shared.updateMessageCount(of:friend, to:messageCount)
        self.dismiss(animated: true, completion:nil)
    }

    func unlinkDidTap() {
        let ac = AlertManager.shared.alertController(.friendDeleteConfirmation, handler: {
            self.friend.unlink(onSuccess: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }, onFailure: { [weak self] err in
                self?.presentAlertController(with: err)
            })

        }, cancelHandler: nil)
        self.present(ac, animated: true, completion: nil)
    }
    
    func emailDidTap() {
        self.openMailCompose(toValue: friend.account!.email)
    }

    func muteDidTap() {
        self.friend.mute(onSuccess: { [weak self] in
            guard let weakself = self else {
                return
            }
            weakself.friendView.setMuteButton(weakself.friend.isMuted)
            
        }, onFailure: { [weak self] err in
            self?.presentAlertController(with: err)
        })
        
    }
    
    func phoneDidTap() {
        self.phoneCall(digits: friend.account!.phone)
    }

    func receiveMessageDidTap(message:Message) {
        let mvc = MessageViewController.instantiate()
        mvc.friend = self.friend
        mvc.message = message.body
        DispatchQueue.main.async {
            self.present(mvc, animated: true, completion: {
                message.delete(onSuccess: { [weak self] in
                    self?.friendView.removeMessage(message: message)
                    
                    }, onFailure: { [weak self] err in
                        self?.presentAlertController(with: err)
                        
                })
            })
        }
    }

    func sendDidTap(message: String) {
        
        self.friend.sendMessage(message, onSuccess: { [weak self] in
            let msg = Message()
            msg.body = message
            self?.friendView.addOutBox(with: msg)
            self?.friendView.clearSendMessageText()
            self?.friendView.showAnnotationView()

            }, onFailure: { [weak self] err in
                self?.presentAlertController(with: err)
        })
    }
    
    func subscribeDidTap() {
        self.showSubscriptionIfNeeded()
    }
    
}

extension FriendViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
