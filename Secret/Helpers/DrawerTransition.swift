//
//  DrawerTransition.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/10.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

enum DrawerSide {
    case none
    case left
}

struct PanState {
    var shouldSlide = false
    var shouldFinish = false
}

class DrawerTransition: UIPercentDrivenInteractiveTransition {
    
    enum TransitionType {
        case none
        case presenting
        case dismissing
    }

    fileprivate var _type: TransitionType = .none

    var isInteractive = false
    var openedSide = DrawerSide.none
    fileprivate var _state = PanState()
    
    func updatePanState(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let velocity = gesture.velocity(in: view)
        let translation = gesture.translation(in: view)
        
        switch openedSide {
        case .none:
            _state.shouldFinish = velocity.x < 0
        case .left:
            _state.shouldFinish = velocity.x >= 0
        }
        
        let enoughSpeed = abs(velocity.x) >= 1000
        let enoughTranslate = abs(translation.x) > view.bounds.size.width/4
        _state.shouldSlide = enoughSpeed || enoughTranslate
    }
    
    func completeInteractive(gesture: UIPanGestureRecognizer) {
        self.completionSpeed = 0.99
        if gesture.state == .ended && _state.shouldFinish && _state.shouldSlide {
            self.finish()
        } else {
            self.cancel()
        }
        self.isInteractive = false
        self.resetPanState()
    }
    
    fileprivate func resetPanState() {
        _state.shouldSlide = false
        _state.shouldFinish = false
    }

}

extension DrawerTransition:UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        _type = .presenting
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        _type = .dismissing
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.isInteractive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.isInteractive ? self : nil
    }
    
}

extension DrawerTransition:UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        
        let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        var foreground = to
        switch _type {
        case .presenting:
            foreground.view.frame.origin.x = -containerView.frame.size.width
            
        case .dismissing:
            foreground = from
            
        case .none:
            break
            
        }
        
        containerView.addSubview(foreground.view)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            switch self._type {
            case .presenting:
                from.view.alpha = 0.6
                to.view.frame.origin.x = 0
            case .dismissing:
                to.view.alpha = 1.0
                from.view.frame.origin.x = -containerView.frame.size.width
            case .none:
                break
            }
            
        }, completion: {(finished) in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }

    
}

