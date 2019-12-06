//
//  Func_Notification.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 14/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

func NotiValue(_ noti:EnumMyNoti) -> NSNotification.Name {
    return NSNotification.Name(noti.rawValue)
}

func WhenReceiveNoti(_ observer:Any, _ selector:Selector, noti:EnumMyNoti) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: NotiValue(noti), object: nil)
}

func PostNoti(noti:EnumMyNoti) {
    NotificationCenter.default.post(name: NotiValue(noti), object: nil)
}

