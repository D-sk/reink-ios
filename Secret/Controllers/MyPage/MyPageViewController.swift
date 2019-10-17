//
//  MyPageViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import SafariServices

class MyPageViewController: AbstractViewController {

    @IBOutlet weak var _myPageView: MyPageView!

    fileprivate var _selectedHelp: HelpBook!
    
    let transition:DrawerTransition = DrawerTransition()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.navigationController?.transitioningDelegate = transition
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        _myPageView.delegate = self
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _myPageView.setAccount(RealmManager.shared.myAccount())
        _myPageView.setPasscodeSettings(UserDefaultsManager.shared.passcode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHelpBook" {
            (segue.destination as! HelpBookViewController).helpBook = _selectedHelp
        }
    }
}

extension MyPageViewController {
    
    @objc func handlePanGesture(_ sender:UIPanGestureRecognizer){
        switch sender.state {
        case .began:
            self.transition.isInteractive = true
            self.transition.openedSide = .none
            self.dismiss(animated: true, completion: nil)
            
        case .changed:
            self.transition.updatePanState(gesture: sender)
            let translation = sender.translation(in: self.view)
            if translation.x > 0 {
                return
            }
            let perc = fabs(translation.x / self.view.bounds.width)
            self.transition.update(perc)
            
        case .ended, .cancelled, .failed:
            self.transition.completeInteractive(gesture: sender)
            
        default:
            break
        }

    }
}

extension MyPageViewController: MyPageViewDelegate {
    
    func accountDidTap() {
        self.performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    func qrCodeDidTap() {
        self.performSegue(withIdentifier: "showQRCode", sender: self)
    }

    func helpDidTap(help: HelpBook) {
        _selectedHelp = help
        self.performSegue(withIdentifier: "showHelpBook", sender: self)
    }
    
    func informationDidTap(url: URL) {
        let safari = SFSafariViewController(url: url)
        self.present(safari, animated: true, completion: nil)
    }
    
    func passcodeSettingsValueChanged(isOn: Bool) {
        UserDefaultsManager.shared.passcode = isOn
    }
    
    func logoutDidTap() {
        DispatchQueue.main.async {
            let ac = AlertManager.shared.alertController(.logoutConfrimation, handler: {
                APIManager.shared.logout(onSuccess: {
                    resetAll()
                    UIApplication.shared.keyWindow?.rootViewController = InitialViewController.instantiate()
                }, onFailure: { [weak self] err in
                    self?.presentAlertController(with: err)
                    
                })
            }, cancelHandler: nil)
            
            self.present(ac, animated: true, completion: nil)
        }
    }
}
