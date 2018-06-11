//
//  OverlayTransition.swift
//  Lifework
//
//  Created by Daisuke Sugimoto on 2016/07/29.
//  Copyright © 2016年 fiole.co. All rights reserved.
//

import UIKit

class OverlayTransition: NSObject {
	enum TransitionType {
		case none
		case presenting
		case dismissing
	}
	fileprivate var _type: TransitionType = .none
	
}

extension OverlayTransition:UIViewControllerTransitioningDelegate {
	
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		_type = .presenting
		return self
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		_type = .dismissing
		return self
	}
	
}


extension OverlayTransition:UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.5
	}
	
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let duration = transitionDuration(using: transitionContext)
		let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
		let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
		let containerView = transitionContext.containerView
		var foregroundViewController = toViewController
		switch _type {
		case .presenting:
			foregroundViewController.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
		case .dismissing:
			foregroundViewController = fromViewController
			
		case .none:
			break
			
		}
		
		containerView.addSubview(foregroundViewController.view)
		
		UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
			switch self._type {
			case .presenting:
				foregroundViewController.view.transform = CGAffineTransform.identity
				foregroundViewController.view.alpha = 1.0
			case .dismissing:
				foregroundViewController.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
				foregroundViewController.view.alpha = 0.0
			case .none:
				break
			}
			if self._type == .presenting {
				
			}else{
				
			}
			
			}, completion: {(finished) in
				
				foregroundViewController.view.transform = CGAffineTransform.identity
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}}
