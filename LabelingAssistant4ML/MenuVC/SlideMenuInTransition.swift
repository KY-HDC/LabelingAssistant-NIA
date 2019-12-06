//
//  SlideInTransition.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 20/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class SlideMenuInTransition: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting  = false
    let dimmingView = UIView()
    var containerView = UIView()
    var toViewController = UIViewController()
    var fromViewController = UIViewController()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.toViewController = transitionContext.viewController(forKey: .to)!
        self.fromViewController = transitionContext.viewController(forKey: .from)!
        
        containerView = transitionContext.containerView

        if isPresenting {
            dimmingView.backgroundColor = .black
            dimmingView.alpha = 0.0
            containerView.addSubview(dimmingView)
            
            self.dimmingView.translatesAutoresizingMaskIntoConstraints = false
            self.dimmingView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor).isActive = true
            self.dimmingView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
            self.dimmingView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor).isActive = true
            self.dimmingView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor).isActive = true

            containerView.addSubview(self.toViewController.view)
            
            // 메뉴 뷰의 폭은 세로 가로 길이 중 작은 쪽 길이의 40%로 설정
            let finalWidth = (containerView.frame.width < containerView.frame.height) ? containerView.frame.width * 0.4 : containerView.frame.height * 0.4
            
            self.toViewController.view.frame = CGRect(x: -finalWidth, y: 0, width: finalWidth, height: containerView.frame.height)
            self.toViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.toViewController.view.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor).isActive = true
            self.toViewController.view.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
            self.toViewController.view.widthAnchor.constraint(equalToConstant: finalWidth).isActive = true

            self.toViewController.view.transform = CGAffineTransform(translationX: -finalWidth, y: 0)
        }
        
        let transform = {
            self.dimmingView.alpha = 0.5
            self.toViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        let identity = {
            self.dimmingView.alpha = 0.0
            //self.fromViewController.view.transform = .identity
            self.fromViewController.view.transform = CGAffineTransform(translationX: -self.fromViewController.view.frame.width, y: 0)
        }
        
        let duration = transitionDuration(using: transitionContext)
        let isCanceled = transitionContext.transitionWasCancelled
        UIView.animate(withDuration: duration, animations: {
            self.isPresenting ? transform() : identity()
        }) { (_) in
            transitionContext.completeTransition(!isCanceled)
        }
        
    }
    
}
