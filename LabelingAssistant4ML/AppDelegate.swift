//
//  AppDelegate.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 2018. 10. 10..
//  Copyright © 2018년 uBiz Information Technology. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // 손가락 터치 포지션을 동그라미로 표시하기 위해서는 위 한줄을 막고 아래를 풀어야 함 mjson
    //var window: UIWindow? = FingerTips(frame: UIScreen.main.bounds)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if (FirstDidBecomeActive) {
            let ud = MyUserDefaults()
            ud.getUserDefaults()
            //FirstDidBecomeActive = false
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

//        if (FirstDidBecomeActive) {
//            let ud = MyUserDefaults()
//            ud.getUserDefaults()
//            //FirstDidBecomeActive = false
//        }

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.synchronize()
    }


}

