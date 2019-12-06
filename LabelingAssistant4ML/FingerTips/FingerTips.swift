//
//  FingerTips.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 28/02/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class FingerTips: UIWindow {

    var _touchImage:UIImage? = nil
    var touchAlpha:CGFloat = 0.5
    var fadeDuration:TimeInterval = 0.3
    var strokeColor:UIColor = UIColor.black
    var fillColor:UIColor = UIColor.white
    var alwaysShowTouches:Bool = true
    
    var _overlayWindow:UIWindow? = nil
    var active:Bool = false
    var fingerTipRemovalScheduled:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        myInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func myInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.screenConnect(notification:)), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.screenDisConnect(notification:)), name: UIScreen.didDisconnectNotification, object: nil)
        
        updateFingertipsAreActive()
    }
    
    @objc func screenConnect(notification:NSNotification)
    {
        updateFingertipsAreActive()
    }
    
    @objc func screenDisConnect(notification:NSNotification)
    {
        updateFingertipsAreActive()
    }
    
    func anyScreenIsMirrored() -> Bool {
        if UIScreen.instancesRespond(to:#selector(getter: UIScreen.mirrored)) == false {
            return false
        }
        
        for screen in UIScreen.screens
        {
            if screen.mirrored != nil {
                return true
            }
        }
        
        return false
    }
    
    func updateFingertipsAreActive() {
        
        if alwaysShowTouches
        {
            self.active = true
        }
        else
        {
            self.active = self.anyScreenIsMirrored()
        }
    }
    
    func setAlwaysShowTouches(flag:Bool) {
        if alwaysShowTouches != flag
        {
            alwaysShowTouches = flag;
            updateFingertipsAreActive()
        }
    }
    
    override func sendEvent(_ event: UIEvent) {
        if self.active {
            let allTouches = event.allTouches
            
            for touch in allTouches!{
                
                switch (touch.phase)
                {
                case UITouchPhase.began,
                     UITouchPhase.moved,
                     UITouchPhase.stationary:
                    
                    var touchView = self.overlayWindow.viewWithTag(touch.hash) as? FingerTipView
                    
                    if (touch.phase != UITouch.Phase.stationary && touchView != nil && (touchView?.fadingOut)!)
                    {
                        touchView?.removeFromSuperview()
                        touchView = nil
                    }
                    
                    if (touchView == nil && touch.phase != UITouch.Phase.stationary)
                    {
                        touchView = FingerTipView(image: self.touchImage)
                        self.overlayWindow.addSubview(touchView!)
                    }
                    
                    if touchView?.fadingOut == false {
                        touchView?.alpha = self.touchAlpha;
                        touchView?.center = touch.location(in: self.overlayWindow)
                        touchView?.tag = touch.hash;
                        touchView?.timestamp = touch.timestamp;
                        touchView?.shouldAutomaticallyRemoveAfterTimeout = shouldAutomaticallyRemoveFingerTipForTouch(touch: touch)
                    }
                    break
                case UITouchPhase.ended,
                     UITouchPhase.cancelled:
                    removeFingerTipWithHash(hash: touch.hash, animated: true)
                    break
                }
            }
        }
        
        super.sendEvent(event)
        
        scheduleFingerTipRemoval()
    }
    
    func scheduleFingerTipRemoval() {
        if self.fingerTipRemovalScheduled {
            return
        }
        
        self.fingerTipRemovalScheduled = true
        self.perform( #selector(self.removeInactiveFingerTips), with: nil, afterDelay: 0.1)
    }
    
    func cancelScheduledFingerTipRemoval() {
        self.fingerTipRemovalScheduled = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.removeInactiveFingerTips), object: nil)
    }
    
    @objc func removeInactiveFingerTips() {
        self.fingerTipRemovalScheduled = false
        
        let now = ProcessInfo().systemUptime
        let REMOVAL_DELAY = 0.2
        
        for touchView in self.overlayWindow.subviews
        {
            if touchView.isKind(of: FingerTipView.self) == false{
                continue
            }
            
            let thisView = touchView as! FingerTipView
            if thisView.shouldAutomaticallyRemoveAfterTimeout && now > (thisView.timestamp + REMOVAL_DELAY) {
                removeFingerTipWithHash(hash: thisView.tag, animated: true)
            }
        }
        
        if self.overlayWindow.subviews.count > 0 {
            scheduleFingerTipRemoval()
        }
    }
    
    func removeFingerTipWithHash(hash:NSInteger, animated:Bool)
    {
        let touchView = self.overlayWindow.viewWithTag(hash)
        if touchView == nil || touchView?.isKind(of: FingerTipView.self) == false {
            return
        }
        
        let thisView = touchView as! FingerTipView
        if thisView.fadingOut {
            return
        }
        
        let animationsWereEnabled = UIView.areAnimationsEnabled
        
        if animated {
            UIView.setAnimationsEnabled(true)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(self.fadeDuration)
        }
        
        thisView.frame = CGRect(x: thisView.center.x - thisView.frame.size.width,
                                y: thisView.center.y - thisView.frame.size.height,
                                width: thisView.frame.size.width  * 2,
                                height: thisView.frame.size.height * 2)
        
        thisView.alpha = 0.0
        
        if animated {
            UIView.commitAnimations()
            UIView.setAnimationsEnabled(animationsWereEnabled)
        }
        
        thisView.fadingOut = true
        thisView.perform(#selector(self.removeFromSuperview), with: nil, afterDelay: self.fadeDuration)
    }
    
    func shouldAutomaticallyRemoveFingerTipForTouch(touch:UITouch) -> Bool {
        var view = touch.view
        view = view?.hitTest(touch.location(in: view), with: nil)
        
        while (view != nil)
        {
            if (view?.isKind(of: UITableViewCell.self))!
            {
                for recognizer in touch.gestureRecognizers! {
                    if recognizer.isKind(of: UISwipeGestureRecognizer.self) {
                        return true
                    }
                }
            }
            
            if (view?.isKind(of: UITableView.self))! {
                if touch.gestureRecognizers?.count == 0{
                    return true
                }
            }
            
            view = view?.superview
        }
        
        return false
    }
    
    var overlayWindow:UIWindow {
        if _overlayWindow != nil {
            return _overlayWindow!
        }
        _overlayWindow = FingerTipOverlayWindow(frame: self.frame)
        _overlayWindow?.rootViewController = (_overlayWindow as! FingerTipOverlayWindow)._rootViewController
        _overlayWindow?.isUserInteractionEnabled = false
        _overlayWindow?.windowLevel = UIWindow.Level.statusBar
        _overlayWindow?.backgroundColor = UIColor.clear
        _overlayWindow?.isHidden = false
        
        return _overlayWindow!
    }
    
    var touchImage:UIImage {
        if _touchImage != nil {
            return _touchImage!
        }
        let clipPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        UIGraphicsBeginImageContextWithOptions(clipPath.bounds.size, false, 0)
        
        //let drawPath = UIBezierPath(arcCenter: CGPoint(x: 25, y: 25), radius: 22.0, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        
        let drawPath = UIBezierPath(arcCenter: CGPoint(x: 25, y: 25), radius: 22.0, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)

        drawPath.lineWidth = 2.0;
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        drawPath.stroke()
        drawPath.fill()
        
        clipPath.addClip()
        
        _touchImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return _touchImage!
    }

}
