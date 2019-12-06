//
//  Declare_Variables.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 30/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

//var ServerAddress = "http://192.168.0.70"
var ServerAddress = "http://220.69.215.105"  // 서버 IP
var ServerPort = 3001
//var ServerWebViewPort = 3002
var ServerWebViewPort = 3001
var ServerURL = String(format: "%@:%d/", ServerAddress, ServerPort)
//var ServerWebView = String(format: "%@:%d/", ServerAddress, ServerWebViewPort)
var ServerWebView = String(format: "%@:%d/", ServerAddress, ServerWebViewPort)
//var ServerWebView = "http://192.168.0.70:3001/"
var ILA4ML_URL_PROC = ServerURL + "proc"
var ILA4ML_URL_GETIMAGE = ServerURL + "getImage"

var LastURLErrorMessage:String = "No Error"     // 서버로 요청한 후의 마지막 에러 메시지 저장
var ResponseErrorCode = 0;                      // 실패일 경우 에러 코드
let RequestTimeout = 50                        // 서버 요청 후 최대 응답시간, 0.1초단위(요청 함수 콜하는 곳)
let RequestURLTimeout = 40                      // 서버 요청 후 최대 응답시간, 0.1초단위(실제 요청함수 내에서)

var FirstDidBecomeActive = true

// -----------------------------------------------------------------------
// 어느 화면에서 어떤 동작을 한 후 unwind되었는지 확인용
// -----------------------------------------------------------------------
var isNewLogined = false
var isFromLoginMenu = false
var isNewProjectBegan = false
var isFromProjectMenu = false
var isFromSettingMenu = false

// -----------------------------------------------------------------------
// 라벨링 검토 모드
// -----------------------------------------------------------------------
var IsReviewMode = false                // 리뷰 모드인지
var LeftIndexOnReviewMode = -1          // 리뷰 모드시 좌측 라벨 값
var RightIndexOnReviewMode = -1         // 리뷰 모드시 우측 라벨 값
var IncludeLabelingDoneImage = false    // 라벨링 완료한 이미지도 탐색할 것인지
var IsSettingValueChanged = false       // setting치에서 무엇인가 변경이 되었는지...

// -----------------------------------------------------------------------
// 현재 시간을 특정 포맷으로 콘솔에 출력
// -----------------------------------------------------------------------
func SetServerAddress(_ addr:String) {
    
    ServerAddress = addr
    ServerURL =  String(format: "%@:%d/", ServerAddress, ServerPort)
    //ServerWebView =  String(format: "%@:%d/", ServerAddress, ServerWebViewPort)
    ILA4ML_URL_PROC = ServerURL + "proc"
    ILA4ML_URL_GETIMAGE = ServerURL + "getImage"

    UserDefaults.standard.set(ServerAddress, forKey: DefaultKey_ServerAddress)
    
}
