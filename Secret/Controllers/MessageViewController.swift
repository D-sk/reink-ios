//
//  MessageViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/11/05.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class MessageViewController: AbstractViewController {

    @IBOutlet weak var messageView: MessageView!
    var friend:Friend!
    var message:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)

        self.messageView.delegate = self
        self.messageView.setMessage(with: self.message)
        self.messageView.setThumbnail(with: self.friend.account!.imageURL())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
        
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

extension MessageViewController: MessageViewDelegate {
    func closeDidTap() {
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    func sendDidTap(message:String) {
        self.friend.sendMessage(message, onSuccess: { [weak self] in
            let msg = Message()
            msg.body = message
            self?.messageView.addOutBox(with: msg)
            self?.messageView.clearSendMessageText()
            self?.messageView.showAnnotationView()

        }, onFailure: { [weak self] err in
            self?.presentAlertController(with: err)

        })
    }
}
