//
//  ContactViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/08/12.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: AbstractViewController {


    @IBOutlet weak var contactView: ContactView!
    let transition:OverlayTransition = OverlayTransition()
    var contact:Contact!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transitioningDelegate = transition
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.contactView.delegate = self
        contactView.setContact(contact)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*z
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func phoneCall(digits:String) {
        if let url = URL(string: "tel://" + digits) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
        }
    }
    
    func openMailCompose(toValue:String){
        let vc = MFMailComposeViewController()
        vc.setToRecipients([toValue])
        vc.mailComposeDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}


extension ContactViewController: ContactViewDelegate {
    func phoneDidTap(){
        if contact.phoneNumbers.count == 1 {
            self.phoneCall(digits: contact.phoneNumbers[0].digits)
        } else {
            let ac = contact.phoneActionController(phoneAction: { digits in
                self.phoneCall(digits: digits)
            })
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func mailDidTap(){
        if contact.emailAddresses.count == 1 {
            self.openMailCompose(toValue: contact.emailAddresses[0].value)
        } else {
            let ac = contact.mailActionController(mailAction: { value in
                self.openMailCompose(toValue: value)
            })
            self.present(ac, animated: true, completion: nil)
        }        
    }
    
    func closeDidTap(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension ContactViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
