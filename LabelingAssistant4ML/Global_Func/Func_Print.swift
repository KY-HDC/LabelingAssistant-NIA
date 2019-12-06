//
//  Func_Print.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 14/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

// -----------------------------------------------------------------------
// 현재 시간을 특정 포맷으로 콘솔에 출력
// -----------------------------------------------------------------------
func PrintDate() {
    let d = Date()
    let df = DateFormatter()
    df.dateFormat = "y-MM-dd H:m:ss.SSS"
    
    print(df.string(from: d))
}
