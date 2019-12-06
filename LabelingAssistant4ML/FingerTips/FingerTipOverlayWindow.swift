//
//  FingerTipOverlayWindow.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 28/02/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class FingerTipOverlayWindow: UIWindow {

    var _rootViewController:UIViewController {
        for window in UIApplication.shared.windows {
            if self == window {
                continue
            }
            
            let realRootViewController = window.rootViewController
            if realRootViewController != nil {
                return realRootViewController!
            }
        }
        return super.rootViewController!
    }
    
}
