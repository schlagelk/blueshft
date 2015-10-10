//
//  SimpleTransitioner.swift
//  blueshft
//
//  Created by Kenny Schlagel on 10/10/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class SimpleTransitioner: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation: Bool = false
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = fromViewController!.view
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let toView = toViewController!.view
        
        var containerView: UIView = transitionContext.containerView()!
        if isPresentation {
            containerView.addSubview(toView)
        }
        
        var animatingViewController = isPresentation ? toViewController : fromViewController
        var animatingView = animatingViewController!.view
        
        var appearedFrame = transitionContext.finalFrameForViewController(animatingViewController!)
        var dismissedFrame = appearedFrame
        dismissedFrame.origin.y += dismissedFrame.size.height
        
        let initialFrame = isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = isPresentation ? appearedFrame : dismissedFrame
        animatingView.frame = initialFrame
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 300.0, initialSpringVelocity: 5.0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.BeginFromCurrentState], animations:{
                animatingView.frame = finalFrame
            }, completion:{ (value:Bool) in
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
            })
    }
}

class SimpleTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = DetailPresentationController(presentedViewController: presented, presentingViewController: presenting)
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animationController = SimpleTransitioner()
        animationController.isPresentation = true
        return animationController
    }
}