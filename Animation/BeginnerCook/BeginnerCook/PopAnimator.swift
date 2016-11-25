//
//  PopAnimator.swift
//  BeginnerCook
//
//  Created by altair21 on 16/11/25.
//  Copyright © 2016年 Razeware LLC. All rights reserved.
//

import UIKit

class PopAnimator: NSObject {
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    var dismissCompletion: (()->Void)?
}

extension PopAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let herbView = presenting ? toView : transitionContext.view(forKey: .from)!
        let herbVC = presenting ? transitionContext.viewController(forKey: .to)! as! HerbDetailsViewController : transitionContext.viewController(forKey: .from)! as! HerbDetailsViewController
        
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            herbView.clipsToBounds = true
            
            herbVC.containerView.alpha = 0.0
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: herbView)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            herbView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
            herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            herbVC.containerView.alpha = self.presenting ? 1.0 : 0.0
        }, completion: { _ in
            if !self.presenting {
                self.dismissCompletion?()
            }
            transitionContext.completeTransition(true)
        })
        
        let cornerRadius = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadius.fromValue = presenting ? 20.0 / xScaleFactor : 0.0
        cornerRadius.toValue = presenting ? 0.0 : 20.0 / xScaleFactor
        cornerRadius.duration = duration / 2
        herbView.layer.cornerRadius = presenting ? 0.0 : 20.0 / xScaleFactor
        herbView.layer.add(cornerRadius, forKey: nil)
    }
}
