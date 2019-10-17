//
//  FlipViewController.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/10/11.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

class FlipViewController: AbstractViewController {

    enum SwitchState {
        case next
        case prev
        case none
    }
    
    enum PanState{
        case right
        case left
        case none
    }
    
    
    fileprivate var _containerEdge:CGFloat = 0.0
    fileprivate var _containerWidth:CGFloat = 0.0
    fileprivate var _switchState:SwitchState = .none
    fileprivate var _panState:PanState = .none
    fileprivate var _isSwithcing:Bool = false
    
    var tabIndex:Int = 0
    var viewControllers:Array<AbstractViewController> = [AbstractViewController]()
    var container:UIView = UIView(frame:CGRect.zero){
        didSet{
            _containerEdge = container.frame.maxX
            _containerWidth = container.frame.width
        }
    }
    
    var willSwitch:(() -> Void)?
    var didCancel:(() -> Void)?
    var didSwitch:(() -> Void)?

    let flipVelocity:CGFloat = 320.0
    let flipTranslation:CGFloat = 100.0
    
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

    func addViewController(viewController:UIViewController){
        
        self.container.addSubview(viewController.view)
        self.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        
    }
    
    func removeViewController(viewController:UIViewController){
        
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        
    }

    //MARK: Switching Tab
    func switchViewController(state:SwitchState){
        if _isSwithcing {
            return
        }
        _isSwithcing = true
        switch state {
        case .prev:
            self.tabIndex -= 1
        case .next:
            self.tabIndex += 1
        case .none:
            return
        }
        self.animateTabPannel(state: state)
    }
    
    func switchViewController(index:Int, animated:Bool=true){
        if _isSwithcing || self.tabIndex == index{
            return
        }else{
            _isSwithcing = true
            let vc = self.viewControllers[index]
            
            if self.tabIndex > index {
                
                _switchState = .prev
                vc.view.frame.origin.x = -_containerWidth
                
            }else if self.tabIndex < index {
                
                _switchState = .next
                vc.view.frame.origin.x = _containerWidth
                
            }
            
            self.addViewController(viewController: vc)
            self.tabIndex = index
            self.animateTabPannel(state: _switchState, animated:animated)
        }
    }
    
    func cancelFlip(){
        
        let state = _switchState
        if let currentView = self.childViewControllers.first?.view{
            
            let duration = Double(fabs(currentView.frame.minX)/_containerWidth)
            let targetView = self.childViewControllers.last?.view
            UIView.animate(withDuration: duration, animations: {
                
                switch state {
                case .prev:
                    
                    targetView?.frame.origin.x = -self._containerWidth
                    
                case .next:
                    
                    targetView?.frame.origin.x = self._containerWidth
                    
                case .none:
                    break
                }
                
                currentView.frame.origin.x = 0.0
                
            }, completion: {completed in
                if state != .none {
                    if let vc = self.childViewControllers.last{
                        self.removeViewController(viewController: vc)
                    }
                    
                }
            })
            
            _switchState = .none
            
        }
    }
    
    private func animateTabPannel(state:SwitchState, animated:Bool=true){
        
        if let targetView = self.childViewControllers.last?.view{
            
            var duration = 0.0
            if animated {
                duration = 0.3*Double(fabs(targetView.frame.minX)/self.view.bounds.width)
            }
            
            let currentView = self.childViewControllers.first?.view
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                
                switch state {
                case .prev:
                    
                    currentView?.frame.origin.x = self._containerEdge
                    
                case .next:
                    
                    currentView?.frame.origin.x = -self._containerWidth
                    
                case .none:
                    return
                }
                
                targetView.frame.origin.x = 0.0
                
            }, completion: {completed in
                
                if let vc = self.childViewControllers.first{
                    self.removeViewController(viewController: vc)
                }
                self._isSwithcing = false
                
            })
            self.didSwitch?()
        }
        self._switchState = .none
    }
    
    func addPreviousViewController(){
        if self.tabIndex > 0 {
            _switchState = .prev
            let vc = self.viewControllers[self.tabIndex - 1]
            vc.view.frame.origin.x = -_containerWidth
            self.addViewController(viewController: vc)
        }else{
            _switchState = .none
        }
    }
    
    func addNextViewController() {
        if self.tabIndex < self.viewControllers.count-1 {
            _switchState = .next
            let vc = self.viewControllers[self.tabIndex + 1]
            vc.view.frame.origin.x = _containerEdge
            self.addViewController(viewController: vc)
        }else{
            _switchState = .none
        }
    }
    
    func resetFlipViewController(_ state:SwitchState){
        self.viewControllers[self.tabIndex].view.frame.origin.x = 0.0
        if let lastVC = self.childViewControllers.last{
            self.removeViewController(viewController: lastVC)
        }
        switch state {
        case .prev:
            self.addPreviousViewController()
        case .next:
            self.addNextViewController()
        case .none:
            break
        }
        
        
    }

}

//MARK: PanGestureDelegate
extension FlipViewController{
    func panGesture() -> UIPanGestureRecognizer{
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        return gesture
    }
    
    @objc func handlePanGesture(_ gesture:UIPanGestureRecognizer){
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        
        switch gesture.state {
        case .began:
            
            if fabs(velocity.y) < fabs(velocity.x) && velocity.x > 0 && self.tabIndex > 0{
                self.willSwitch?()
                _panState = .right
                self.addPreviousViewController()
                
            } else if fabs(velocity.y) < fabs(velocity.x) && velocity.x < 0 && self.tabIndex < viewControllers.count-1 {
                self.willSwitch?()
                _panState = .left
                self.addNextViewController()
                
            } else {
                _panState = .none
            }
            
            
        case .changed:
            
            self.gestureTranslation(translation)
            
        case .ended:
            
            if ( _switchState == .prev && (velocity.x > flipVelocity || translation.x > _containerWidth/2))
                || ( _switchState == .next && (velocity.x < -flipVelocity || translation.x < -_containerWidth/2)) {
                
                self.switchViewController(state: _switchState)
                
            }else{
                
                self.cancelGesture()
            }
            
            self._panState = .none
            
        default:
            self.cancelGesture()
        }
        
    }
    
    
    private func gestureTranslation(_ translation:CGPoint){
        let currentView = self.childViewControllers.first?.view
        let targetView = self.childViewControllers.last?.view
        
        switch _panState {
            
        case .right:
            
            
            if translation.x < 0 {
                if self.tabIndex < self.viewControllers.count-1 {
                    _panState = .left
                    self.resetFlipViewController(.next)
                }else{
                    currentView?.frame.origin.x = 0.0
                    targetView?.frame.origin.x = -_containerWidth
                }
                
            }else if translation.x > _containerEdge {
                currentView?.frame.origin.x = _containerEdge
                targetView?.frame.origin.x = 0.0
                
            }else {
                
                currentView?.frame.origin.x = translation.x
                targetView?.frame.origin.x = -_containerWidth + translation.x
                
            }
            
            
        case .left:
            
            if translation.x > 0 {
                
                if self.tabIndex > 0{
                    _panState = .right
                    self.resetFlipViewController(.prev)
                }
                else{
                    currentView?.frame.origin.x = 0.0
                    targetView?.frame.origin.x = -_containerWidth
                    
                }
                
            }else if translation.x < -_containerEdge {
                currentView?.frame.origin.x = -_containerWidth
                targetView?.frame.origin.x = 0.0
                
            }else{
                currentView?.frame.origin.x = translation.x
                targetView?.frame.origin.x = _containerEdge + translation.x
                
            }
            
        case .none:
            currentView?.frame.origin.x = translation.x/2
        }
    }
    
    private func cancelGesture(){
        self.cancelFlip()
        _panState = .none
        self.didCancel?()
    }
    
}
