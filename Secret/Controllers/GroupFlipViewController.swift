//
//  GroupFlipViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/03/04.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import LocalAuthentication
import SafariServices

class GroupFlipViewController: FlipViewController {

    @IBOutlet fileprivate weak var _scrollView: UIScrollView!
    @IBOutlet fileprivate weak var _separator: UIView!
    @IBOutlet fileprivate weak var _containerView: UIView!
    @IBOutlet fileprivate weak var _textField: UITextField!
    
    fileprivate var _edgePaned:Bool = false
    fileprivate var _drawerViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyPageNavigation") as! UINavigationController
    
    fileprivate var _searchViewController:ContactListViewController!
    
    fileprivate var _notificationToken: NotificationToken? = nil
    fileprivate var _groups:Results<Group>! {
        didSet{
            _notificationToken?.invalidate()
            
            _notificationToken = _groups.observe {(changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    
                    self.refreshContents()
                    
                case .update(_, let deletions, let insertions, let modifications):
                    
                    if self.viewControllers.count == 0 {
                        self.refreshContents()
                        
                    }else if deletions.count > 0 {
                        self.refreshContents()
                        
                    }else if insertions.count > 0 {
                        for i in insertions {
                            let grp = self._groups[i]
                            let vc = self.contactListViewController()
                            vc.group = grp
                            self.insertViewController(with: grp, at: i)
                            
                        }

                    }else if modifications.count > 0 {
                        
                        for m in modifications {
                            let grp = self._groups[m]
                            let vc = self.viewControllers[m] as! ContactListViewController
                            vc.group = grp
                            
                            var originX: CGFloat = 0.0
                            for sv in self._scrollView.subviews {
                                guard let tab = sv as? SwitchTab else {
                                    continue
                                }
                                if tab.tag == m {
                                    tab.title = grp.name
                                    tab.color = grp.color()
                                    originX = tab.frame.maxX
                                } else if tab.tag > m {
                                    tab.frame.origin.x = originX
                                    originX = tab.frame.maxX
                                }
                                
                            }
                            
                        }
                    }
                    
                case .error(let error):
                    fatalError("\(error)")
                    
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
        
        self.didSwitch = {
            self.scrollToSelectedTab()
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillEnterForeground),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appDidEnterBackground),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        
        self.syncContacts()
        self.localAuthIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaultsManager.shared.isFirstLogin {
            let vc = HelpListViewController.instantiate()
            self.present(vc, animated: true, completion:{
                UserDefaultsManager.shared.isFirstLogin = false
            })

        } else if UserDefaultsManager.shared.restored == false {
            
            guard let me = RealmManager.shared.myAccount() else {
                resetAll()
                UIApplication.shared.keyWindow?.rootViewController = InitialViewController.instantiate()
                return
            }

            if me.subscribed.isEmpty == false {
                self.present(AlertManager.shared.alertController(.restoreConfirmation, handler: {
                    self.addLoadingView(self.view.frame)
                    StoreManager.shared.restoreDelegate = self
                    StoreManager.shared.restore()
                }, cancelHandler: nil), animated: true, completion: nil)
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _groups == nil {
            self.container = _containerView
            _groups = RealmManager.shared.groups()
        }
        self.setTextFieldWidth()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LocalAuthentication" {
            var error:NSError?
            if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
                let vc = LocalAuthViewController.instantiate()
                if self.presentedViewController != nil {
                    self.presentedViewController!.present(vc, animated: false, completion: {
                        self.setFrontViewIsHidden(isHidden: false)
                    })
                } else {
                    self.present(vc, animated: false, completion: {
                        self.setFrontViewIsHidden(isHidden: false)
                    })
                }
            } else if error != nil {
                self.presentAlertController(with: error!)
            }
            
        } else if segue.identifier == "presentMyPage" {
            self.present(_drawerViewController, animated: true, completion: nil)
        }
    }

    @objc private func appWillEnterForeground() {
        self.registerNotification()
        self.localAuthIfNeeded()
        self.syncContacts()
    }
    
    @objc private func appDidEnterBackground(){
        if UserDefaultsManager.shared.passcode {
            var vc = self.presentedViewController
            while let pvc = vc?.presentedViewController {
                vc = pvc
            }
            if vc is SFSafariViewController {
                vc!.dismiss(animated: false, completion: nil)
            }
        }
        self.setFrontViewIsHidden(isHidden: self.isPassCodeEnabled())
    }

    private func setTextFieldWidth() {
        guard let frame = self.navigationController?.navigationBar.frame else {
            _textField.frame.size.width = 0.0
            return
        }
        
        if _textField.isFirstResponder {
            _textField.frame.size.width = frame.width - frame.height
        } else {
            _textField.frame.size.width = frame.width - frame.height*2
        }
    }

    @objc fileprivate func presentQRScan() {
        self.performSegue(withIdentifier: "presentQRScan", sender: self)
    }
    
    private func rightBarButtonItem()-> UIBarButtonItem? {
        if _textField.isFirstResponder {
            return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.removeSearchViewController))
        } else {
            return UIBarButtonItem(image: #imageLiteral(resourceName: "BarItemProfile"), style: .plain, target: self, action: #selector(self.presentQRScan))
        }
    }
    
    @objc fileprivate func presentMyPage() {
        self.performSegue(withIdentifier: "presentMyPage", sender: self)
    }
    
    private func leftBarButtonItem()-> UIBarButtonItem? {
        if _textField.isFirstResponder {
            return nil
        } else {
            return UIBarButtonItem(image: #imageLiteral(resourceName: "BarItemMenu"), style: .plain, target: self, action: #selector(self.presentMyPage))
        }
    }

    private func setNavigationBar () {
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem()
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem()
        self.setTextFieldWidth()
    }

    @objc private func removeSearchViewController() {
        
        if _textField.isFirstResponder {
            _textField.resignFirstResponder()
        }
        _searchViewController.contactListView.isHidden = true
        _textField.text = ""
        _searchViewController.friends = nil
        _searchViewController.contacts = nil
        _searchViewController.view.backgroundColor = UIColor.overlay
        _searchViewController.willMove(toParentViewController: nil)
        _searchViewController.view.removeFromSuperview()
        _searchViewController.removeFromParentViewController()
        
        self.setNavigationBar()
    }
    
    private func addSearchViewController() {
        
        if _searchViewController == nil {
            _searchViewController = ContactListViewController.instantiate()
            _searchViewController.view.frame.size.height = self.view.frame.height-_scrollView.frame.minY
            _searchViewController.view.frame.origin.y = _scrollView.frame.minY
            _searchViewController.view.backgroundColor = UIColor.overlay
            _searchViewController.contactListView.isHidden = true
            _searchViewController.touchEnded = {
                self.removeSearchViewController()
            }
        }
        
        self.view.addSubview(_searchViewController.view)
        self.addChildViewController(_searchViewController)
        _searchViewController.didMove(toParentViewController: self)
        
        self.setNavigationBar()
    }
    
    private func isPassCodeEnabled() -> Bool {
        return UserDefaultsManager.shared.passcode && UserDefaultsManager.shared.isFirstLogin == false
    }

    private func setFrontViewIsHidden(isHidden:Bool) {
        if let v = self.presentedViewController?.view {
            v.isHidden = isHidden
        }
        _containerView.isHidden = isHidden
    }
    
    func localAuthIfNeeded() {
        if (self.presentedViewController is LocalAuthViewController) {
            self.setFrontViewIsHidden(isHidden:false)
        } else if self.isPassCodeEnabled() {
            self.setFrontViewIsHidden(isHidden:true)
            self.performSegue(withIdentifier: "LocalAuthentication", sender: self)
        }
    }

    func registerNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            guard error == nil else {
                return
            }
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }
    
    func syncContacts(){
        Friend.list(onSuccess:nil, onFailure:{ [weak self] err in
            self?.presentAlertController(with: err)
        })
        CNContactManager.shared.sync()
    }
    
    func refreshContents() {
        for sv in _scrollView.subviews {
            sv.removeFromSuperview()
        }
        self.tabIndex = 0
        self.viewControllers.removeAll()
        self.setViewControllers()
    }

    @IBAction func textFeildEditingDidBegin(_ sender: Any) {
        self.addSearchViewController()
    }

    @IBAction func textFieldTextDidChanged(_ sender: Any) {
        if _textField.markedTextRange != nil {
            return
        }
        
        guard let txt = _textField.text else {
            _searchViewController.view.backgroundColor = UIColor.overlay
            _searchViewController.contactListView.isHidden = true
            return
        }
        
        if txt.isEmpty {
            _searchViewController.view.backgroundColor = UIColor.overlay
            _searchViewController.contactListView.isHidden = true
        } else {
            _searchViewController.view.backgroundColor = UIColor.background
            _searchViewController.contactListView.isHidden = false
        }
        
        _searchViewController.friends = Array(RealmManager.shared.friends(with: txt))
        _searchViewController.contacts = Array(RealmManager.shared.contacts(with: txt))
    }
}

extension GroupFlipViewController {
    
    fileprivate func setViewControllers() {

        for (idx, grp) in _groups.enumerated() {
            if idx == 0 {
                let vc = self.childViewControllers.first as! ContactListViewController
                vc.group = grp
                vc.view.addGestureRecognizer(self.panGesture())
                self.viewControllers.append(vc)
                self.addSwitchTabToScrollView(title: grp.name, color: grp.color(), at: idx)
                _separator.backgroundColor = grp.color()
            } else {
                self.appendViewController(with: grp)
            }
            
        }
        
    }
    
    fileprivate func insertViewController(with group:Group?=nil, at index:Int) {
        let vc = self.contactListViewController()
        
        self.viewControllers.insert(vc, at: index)
        guard let group = group else {
            return
        }
        vc.group = group
        self.addSwitchTabToScrollView(title: group.name, color: group.color(), at: index)
        
    }
    
    fileprivate func appendViewController(with group:Group) {
        let vc = self.contactListViewController()
        vc.group = group
        if self.viewControllers.count == 0 {
            self.addViewController(viewController: vc)
        }
        self.viewControllers.append(vc)
        self.addSwitchTabToScrollView(title: group.name, color: group.color(), at: self.viewControllers.index(of: vc)!)
    }

    fileprivate func contactListViewController() -> ContactListViewController {
        let vc = ContactListViewController.instantiate()
        vc.view.frame.size.height = _containerView.frame.height
        vc.view.addGestureRecognizer(self.panGesture())
        return vc
    }
    
}

extension GroupFlipViewController {
   
    override func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        let vel = gesture.velocity(in: gesture.view)
        let loc = gesture.location(in: gesture.view)
        if gesture.state == .began && self.tabIndex == 0 && loc.x <= 48 && vel.x > 0 {
            _edgePaned = true
        }
        
        if _edgePaned {
            
            guard let vc = _drawerViewController.childViewControllers.first as? MyPageViewController else {
                super.handlePanGesture(gesture)
                return
            }
            switch gesture.state {
            case .began:
                vc.transition.isInteractive = true
                vc.transition.openedSide = .left
                self.present(_drawerViewController, animated: true, completion: nil)
                
            case .changed:
                vc.transition.updatePanState(gesture: gesture)
                let translation = gesture.translation(in: self.view)
                let perc = fabs(translation.x / self.view.bounds.width)
                vc.transition.update(perc)
                
            case .ended, .cancelled, .failed:
                vc.transition.completeInteractive(gesture: gesture)
                _edgePaned = false
            default:
                _edgePaned = false
                break
            }
            
        } else {
            super.handlePanGesture(gesture)
        }
    }
}

extension GroupFlipViewController {
 
    @objc func handleTapGesture(_ gesture:UITapGestureRecognizer){
        guard let v = gesture.view as? SwitchTab else {
            return
        }
        self.switchViewController(index: v.tag)
    }
    
    fileprivate func addSwitchTabToScrollView(title:String, color:UIColor, at index:Int) {
        let tab = self.switchTab(title: title, color: color, at: index)
        
        var originX:CGFloat = 8.0
        if index == 0 {
            tab.frame.origin.x = originX
            originX = tab.frame.maxX
            
        } else {
            
            for v in _scrollView.subviews {
                guard let st = v as? SwitchTab else {
                    continue
                }
                
                if st.tag == index-1 {
                    tab.frame.origin.x = st.frame.maxX
                    originX = tab.frame.maxX
                }
                
                if st.tag > index {
                    st.frame.origin.x = originX
                    originX = st.frame.maxX
                }

            }
        }
        _scrollView.addSubview(tab)
        _scrollView.contentSize.width = originX + 48.0
    }
    
    fileprivate func removeSwitchTabFromScrollView(at index:Int){
        if self.tabIndex == index {
            self.switchViewController(index: self.tabIndex-1)
        }
        var width:CGFloat = 0.0
        for sv in _scrollView.subviews{
            if sv.tag == index {
                width = sv.frame.width
                sv.removeFromSuperview()
            } else if sv.tag > index {
                sv.tag -= 1
                sv.frame.origin.x -= width
            }
        }
        _scrollView.contentSize.width -= width
        self.viewControllers.remove(at: index)
    }

    private func switchTab(title:String, color:UIColor, at index:Int) -> SwitchTab {
        let positionY:CGFloat = 8.0
        let width:CGFloat = 0.0
        let height:CGFloat = _scrollView.frame.height-positionY
        
        let st = SwitchTab(frame:CGRect(x: 0.0, y: positionY, width: width, height: height))
        st.title = title
        st.color = color
        st.tag = index        
        st.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:))))
        st.isSelected = (index==self.tabIndex)
        
        return st
    }
    
    
    fileprivate func scrollToSelectedTab(){
        
        for sv in _scrollView.subviews {
            guard let st = sv as? SwitchTab else {
                return
            }
            st.isSelected = (self.tabIndex==st.tag)
            if self.tabIndex == st.tag {
                if _scrollView.contentSize.width > _scrollView.frame.width{
                    var orgX:CGFloat = st.frame.minX - (_scrollView.center.x - st.frame.width/2)
                    let endX:CGFloat = _scrollView.contentSize.width-_scrollView.bounds.width
                    if st.center.x < _scrollView.center.x{
                        orgX = 0
                    }else if orgX > endX {
                        orgX = endX
                    }
                    _scrollView.setContentOffset(CGPoint(x: orgX, y: 0.0), animated: true)
                    _separator.backgroundColor = st.color
                }
                
                _separator.backgroundColor = st.color

            }
        }
    }
    
}

extension GroupFlipViewController: StoreManagerRestoreDelegate {
    func onSuccess() {
        UserDefaultsManager.shared.restored = true
        self.removeLoadingView()
        StoreManager.shared.restoreDelegate = nil
    }
    
    func onFailed(error: NSError) {
        self.removeLoadingView()
        StoreManager.shared.restoreDelegate = nil
        self.presentAlertController(with: error)
    }
}
