//
//  Func_Color.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 14/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

// ---------------------------------------------------------------------
// user defualt key 정의
// ---------------------------------------------------------------------
let TintColorKey = "TintColor"
let AlarmPopupKey = "AlarmPopup"
let MyToken = "MyToken"

// ---------------------------------------------------------------------
// tint color enum
// ---------------------------------------------------------------------
enum EnumTintColor:Int {
    case Orange = 0, Black, Purple
    var color:UIColor { get {
        switch self {
        case .Orange:
            return UIColor.orange
        case .Black:
            return UIColor.black
        case .Purple:
            return UIColor.purple
        }
        }}
    var title:String { get {
        switch self {
        case .Orange:
            return "Orange"
        case .Black:
            return "Black"
        case .Purple:
            return "Purple"
        }
        }}
}

// ---------------------------------------------------------------------
// tint color 세팅
// ---------------------------------------------------------------------
func SetTintColor(color:UIColor) {
    guard let window = UIApplication.shared.keyWindow else {
        return
    }
    window.tintColor = color
}

// ---------------------------------------------------------------------
// 현재 tint color 가져오기
// ---------------------------------------------------------------------
func SetTintColor() -> UIColor {
    guard let window = UIApplication.shared.keyWindow else {
        return UIColor.orange
    }
    return window.tintColor
}

func ColorWithHexString(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
    let hexint = Int(IntFromHexString(hexStr: hexString))
    let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
    let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
    let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
    let alpha = alpha!
    
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    return color
}

func IntFromHexString(hexStr: String) -> UInt32 {
    var hexInt: UInt32 = 0
    let scanner: Scanner = Scanner(string: hexStr)
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
    scanner.scanHexInt32(&hexInt)
    return hexInt
}
