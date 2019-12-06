//
//  Declare_Enum.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 30/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

// ---------------------------------------------------------------------
// 서버로부터 수신한 JSON포맷의 파싱 결과 관련 Enum
// ---------------------------------------------------------------------
enum ResponseDataError: String, Error {
    case RequestURLForJSON = "ResponseDataError: RequestURLForJSON error"
    case JsonParsing = "ResponseDataError: JSON parsing error"
    case JsonProtocol = "ResponseDataError: JSON Protocol error"
    case ReturnValue = "ResponseDataError: Json key 'success' value is false"
    case Timeout = "ResponseDataError: Timeout(5 seconds)"
    case Unknown = "ResponseDataError: Unknown error"
}

// ---------------------------------------------------------------------
// Notification Enum
// ---------------------------------------------------------------------
enum EnumMyNoti: String, Error {
    case SideMenuButtonTapped = "SideMenuButtonTapped"
    case MenuLoginTapped = "MenuLoginTapped"
    case MenuProjectSettingTapped = "MenuProjectSettingTapped"
    case MenuLabelingTapped = "MenuLabelingTapped"
    case MenuHelpTapped = "MenuHelpTapped"
    case MenuAboutTapped = "MenuAboutTapped"
    case LoginOutEvent = "LoginOutEvent"
    case LabelingBeginEndEvent = "LabelingBeginEndEvent"
    case ImageListChanged = "ImageListChanged"
}

