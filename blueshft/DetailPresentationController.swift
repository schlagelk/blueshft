//
//  DetailPresentationController.swift
//  blueshft
//
//  Created by Kenny Schlagel on 10/10/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import UIKit

class DetailPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    var dimmingView: UIView = UIView()
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        dimmingView.alpha = 0.0
    }
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = self.containerView!.bounds
        dimmingView.alpha = 0.0
        containerView?.insertSubview(dimmingView, atIndex: 0)
        
        let coordinator = presentedViewController.transitionCoordinator()
        if coordinator != nil {
            coordinator!.animateAlongsideTransition({ (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 1.0
            }, completion: nil)
        } else {
            dimmingView.alpha = 1.0
        }
    }
    override func dismissalTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator()
        if coordinator != nil {
            coordinator!.animateAlongsideTransition({ (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 0.0
            }, completion:nil)
        } else {
            dimmingView.alpha = 0.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        dimmingView.frame = containerView!.bounds
        presentedView()!.frame = containerView!.bounds
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    //delegate method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        var animationController = SimpleTransitioner()
        animationController.isPresentation = false
        return animationController
    }
}
