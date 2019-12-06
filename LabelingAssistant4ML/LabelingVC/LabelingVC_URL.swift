//
//  MainVC_URL.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 26/10/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import Foundation
import UIKit

//enum typeURLRequest:Int {
//    case Login = 0, GetImageInfo, GetLabelInfo
//}
//
//enum typeJsonParsing:Int {
//    case LoginCheck = 0, GetImageInfo, GetLabelInfo
//}

class LabelInfo {
    var location: Int?  // 0:좌측, 1:우측
    var value: Int?        // 0, 1
    var text: String?   // Negative, Positive
}


class LabelInfoList {
    var arrayLabelInfo: [LabelInfo] = []
    func getLabelCount(location: Int) -> Int {
        var count = 0
        if (arrayLabelInfo.count == 0) {
            return 0
        }
        for labelInfo in arrayLabelInfo {
            if (labelInfo.location == location) {
                count = count + 1
            }
        }
        return count
    }
    func getLabelText(location: Int) -> [String] {
        var arrayLabelText: [String] = []
        for labelInfo in arrayLabelInfo {
            if (labelInfo.location == location) {
                arrayLabelText.append(labelInfo.text!)
            }
        }
        return arrayLabelText
    }
    func getLabelCode(location: Int) -> [Int] {
        var arrayLabelCode: [Int] = []
        for labelInfo in arrayLabelInfo {
            if (labelInfo.location == location) {
                arrayLabelCode.append(labelInfo.value!)
            }
        }
        return arrayLabelCode
    }
    func getIndexOfLabelCode(location: Int, labelCode: Int) -> Int {
        var index = -1
        for code in getLabelCode(location: location) {
            index = index + 1
            if (code == labelCode) {
                break;
            }
        }
        return index
    }
    init() {
    }
}

class LabelingLocationResult {
    var target_cd: Int?
    var label_cd: Int?
}

class MarkResult {
    var type:MarkType?
    var shape: String?
}

class ImageInfo {
    var id:String?                                      // image ID
    var serverLocation:String?                          // 이미지 파일 서버 위치
    var name:String?                                    // 이름
    var age:Float?                                      // 나이
    var sex:String?                                     // 성별
    var isDrop:String?                                  // Drop 여부
    var isLabelingDone:Bool?                            // 라벨링 여부
    var labelingResult:[LabelingLocationResult] = []    // 라벨링 결과
    var markResult:[MarkResult] = []                    // mark 결과
}

func DoEvents(f: Float) {
    RunLoop.current.run(until: Date(timeIntervalSinceNow: TimeInterval(f)))
}

extension LabelingVC {
    
    enum typeURLRequest:Int {
        case GetLabelList = 0, GetImageInfo, GetImageList, SaveLabelingResult, GetImageOne, DropImage, GetReferImageList, GetLabelListWithResult, End
    }
    
    enum typeJsonParsing:Int {
        case GetLabelList, GetImageInfo, GetImageList, SaveLabelingResult, Success, GetImageOne, DropImage, GetReferImageList, GetLabelListWithResult, ErrorMessage, ErrorCode, End
    }
    
    // 서버로부터 프로젝트에 해당하는 라벨 정보 가져오기
    // ==========================================================================
    func selectLabelList() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .GetLabelList)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.labellist")
        LastURLErrorMessage = ""
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
                    DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let lList:[LabelInfo] =
                        self.parseJson(parsingType: .GetLabelList, jsonFormat: json) as? [LabelInfo]
                        else { throw ResponseDataError.JsonParsing }
                    
                    LabelList.arrayLabelInfo = lList
                    
                    result = true
                    
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(LastURLErrorMessage)")
        }
        
        return result
        
    }
    
    // 서버로부터 프로젝트에 해당하는 라벨 정보(라벨링 결과 포함) 가져오기
    // ==========================================================================
    func selectLabelListWithResult() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .GetLabelListWithResult)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.labellistwithresult")
        LastURLErrorMessage = ""
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
                    DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let lList:[LabelInfo] =
                        self.parseJson(parsingType: .GetLabelList, jsonFormat: json) as? [LabelInfo]
                        else { throw ResponseDataError.JsonParsing }
                    
                    LabelList.arrayLabelInfo = lList
                    
                    result = true
                    
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(LastURLErrorMessage)")
        }
        
        return result
        
    }
    
    // 로그인 체크
    // ==========================================================================
    func selectImageInfo() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .GetImageInfo)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.imageinfo")
        LastURLErrorMessage = ""
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
                    DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let imageInfo:ImageInfo =
                        self.parseJson(parsingType: .GetImageInfo, jsonFormat: json) as? ImageInfo
                        else { throw ResponseDataError.JsonParsing }
                    
                    self.imageInfo = imageInfo
                    
                    result = true
                    print("Login Ok.")
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(LastURLErrorMessage)")
        }

        return result
    }
    

    // 서버에 라벨링 결과 보내기
    // ==========================================================================
    func saveLabelingResult() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .SaveLabelingResult)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.labelingresult")
        LastURLErrorMessage = ""
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
                    DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let temp = self.parseJson(parsingType: .SaveLabelingResult, jsonFormat: json) as? Int
                        else { throw ResponseDataError.JsonParsing }
                    
                    print("save result, complete_count = ", temp)
                    
                    result = true
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(LastURLErrorMessage)")
        }
        
        return result
    }
    
    // 서버에 drop 및 해제 보내기
    // ==========================================================================
    func saveDropResult() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .DropImage)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.dropresult")
        LastURLErrorMessage = ""
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
                    DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let temp = self.parseJson(parsingType: .DropImage, jsonFormat: json) as? String
                        else { throw ResponseDataError.JsonParsing }

                    print("drop result, isDrop = ", temp)

                    result = true
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(LastURLErrorMessage)")
        }
        
        return result
    }
    
    // 서버로부터 이미지 목록 가져오기
    // ==========================================================================
    func selectImageList() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .GetImageList)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.imagelist")
        LastURLErrorMessage = ""
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
                    DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let imageList:[ImageInfo] =
                        self.parseJson(parsingType: .GetImageList, jsonFormat: json) as? [ImageInfo]
                        else { throw ResponseDataError.JsonParsing }
                    
                    ImageList = imageList
                    result = true
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(ResponseDataError.Timeout.rawValue)")
        }

        return result
    }
    
    // 서버로부터 이미지 목록 하나 가져오기
    // ==========================================================================
    func selectImageOne() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .GetImageOne)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.imagerandom")
        LastURLErrorMessage = ""
        ResponseErrorCode = 0

        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {

                    //DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {

                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                        else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        guard let code:Int =
                            self.parseJson(parsingType: .ErrorCode, jsonFormat: json) as? Int
                        else { throw ResponseDataError.JsonParsing }
                        
                        ResponseErrorCode = code
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let imageList:[ImageInfo] =
                        self.parseJson(parsingType: .GetImageOne, jsonFormat: json) as? [ImageInfo]
                        else { throw ResponseDataError.JsonParsing }
                    
                    ImageList = imageList
                    result = true
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(ResponseDataError.Timeout.rawValue)")
        }
        
        print("[selectImageRandomOne] isDownloaded=\(isDownloaded), result=\(result)")
            
        return result
    }
    
    
    // 라벨링 시작/종료 저장
    // ==========================================================================
    func getReferImageList() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .GetReferImageList)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.getReferImageList")
        LastURLErrorMessage = ""
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
                    DoEvents(f: 0.1)
                    if (!success) {
                        if let e = error {
                            throw e
                        }
                        else {
                            throw ResponseDataError.RequestURLForJSON
                        }
                    }
                    
                    guard let getSuccess = self.parseJson(parsingType: .Success, jsonFormat: json) as? Bool
                        else { throw ResponseDataError.JsonParsing }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    guard let iList:[String] =
                        self.parseJson(parsingType: .GetReferImageList, jsonFormat: json) as? [String]
                        else { throw ResponseDataError.JsonParsing }
                    
                    self.referImageList = iList
                    
                    result = true
                    
                }
                catch let error as RequestURLError {
                    if (error == RequestURLError.URLSession) {
                        LastURLErrorMessage = err_msg!
                    }
                    else {
                        LastURLErrorMessage = error.rawValue
                    }
                    //print("[RequestURLError] \(error.rawValue)")
                }
                catch let error as ResponseDataError {
                    if (LastURLErrorMessage == "") {
                        LastURLErrorMessage = error.rawValue
                    }
                    print("[ResponseDataError] \(error.rawValue)")
                }
                catch let error as NSError {
                    LastURLErrorMessage = error.debugDescription
                    print("[NSError  ] \(error.debugDescription)")
                }
                catch let error {
                    LastURLErrorMessage = error.localizedDescription
                    print("[Error  ] \(error.localizedDescription)")
                }
                isDownloaded = true
            }
        }
        
        // 일정 시간(초)동안 기다림
        for _ in 1...RequestTimeout {
            if (isDownloaded) {
                break
            }
            DoEvents(f: 0.1)
        }
        
        if (!isDownloaded && !result) {
            LastURLErrorMessage = ResponseDataError.Timeout.rawValue
            print("[ResponseDataError] \(ResponseDataError.Timeout.rawValue)")
        }
        
        return result
    }
    

    // 서버로부터 json 포맷으로 받기 위한 url request 생성하기
    // ==========================================================================
    func makeURLRequestForJsonFromServer(requestType:typeURLRequest) -> URLRequest? {
        
        var request:URLRequest? = nil
        
        switch requestType {
        case typeURLRequest.GetLabelList:  // 라벨 목록 가져오기
            
            struct RequestLabelList: Codable {
                var proc_name: String?
                var project_cd: String?
            }
            
            var requestLabelList = RequestLabelList();
            requestLabelList.proc_name = "P_GET_LABEL_LIST";
            requestLabelList.project_cd = WorkingProjectCode;
            
            let jsonData = try? JSONEncoder().encode(requestLabelList);
            //let jsonString = String(data: jsonData!, encoding: .utf8)
            //print(jsonString!)
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            //print("endpointUrl:\(endpointUrl)")
            
            // 요청할 최종 url 정의
            // -------------------------------------------------
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData

        case typeURLRequest.GetLabelListWithResult:  // 라벨 목록(라벨링 결과 포함)
            
            struct RequestLabelList: Codable {
                var proc_name: String?
                var project_cd: String?
                var user_id: String?
                var labeling_order: Int?
            }
            
            var requestLabelList = RequestLabelList();
            requestLabelList.proc_name = "P_GET_LABEL_LIST_WITH_RESULT";
            requestLabelList.project_cd = WorkingProjectCode;
            requestLabelList.user_id = LoginID;
            requestLabelList.labeling_order = WorkingLabelingOrder;

            let jsonData = try? JSONEncoder().encode(requestLabelList);
            //let jsonString = String(data: jsonData!, encoding: .utf8)
            //print(jsonString!)
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            //print("endpointUrl:\(endpointUrl)")
            
            // 요청할 최종 url 정의
            // -------------------------------------------------
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData

        case typeURLRequest.GetImageInfo:  // 이미지 정보
            
            struct RequestImageInfo: Codable {
                var proc_name: String?
                var project_cd: String?
                var image_id: String?
            }
            
            var requestImageInfo = RequestImageInfo();
            requestImageInfo.proc_name = "P_GET_IMAGE_INFO"
            requestImageInfo.project_cd = WorkingProjectCode
            requestImageInfo.image_id = imageIDLabel.text

            let jsonData = try? JSONEncoder().encode(requestImageInfo);
            
            //let jsonString = String(data: jsonData!, encoding: .utf8)
            //print(jsonString!)
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            //print("endpointUrl:\(endpointUrl)")
            
            // 요청할 최종 url 정의
            // -------------------------------------------------
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData

        case typeURLRequest.GetImageList:  // 이미지 목록
            
            struct RequestImageList: Codable {
                var proc_name: String?
                var project_cd: String?
                var user_id: String?
                var labeling_order: Int?
            }
            
            var requestImageList = RequestImageList();
            requestImageList.proc_name = "P_GET_IMAGE_LIST"
            requestImageList.user_id = LoginID
            requestImageList.project_cd = WorkingProjectCode
            requestImageList.labeling_order = WorkingLabelingOrder
            
            let jsonData = try? JSONEncoder().encode(requestImageList);
            //let jsonString = String(data: jsonData!, encoding: .utf8)
            //print(jsonString!)
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            //print("endpointUrl:\(endpointUrl)")
            
            // 요청할 최종 url 정의
            // -------------------------------------------------
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData
            
        case typeURLRequest.GetImageOne:  // 이미지 목록 랜덤하게 1개만
            
            struct LabelIndexOnReviewMode: Codable {
                var target_cd: Int?
                var label_cd: Int?
            }
            
            struct RequestImageList: Codable {
                var proc_name: String?
                var project_cd: String?
                var user_id: String?
                var labeling_order: Int?
                var isTotalExplore: Int?
                var prevNextFlag: String?
                var currentImageId: String?
                var isReviewMode: Int?
                var LabelIndexesOnReviewMode: [LabelIndexOnReviewMode] = []
            }
            // isTotalExploreSwitch : 1이면 전체중에서 1개, 0이면 라벨링이 안된 것 중에 1개
            
            var requestImageList = RequestImageList();
            requestImageList.proc_name = "P_GET_IMAGE_ONE"
            requestImageList.user_id = LoginID
            requestImageList.project_cd = WorkingProjectCode
            requestImageList.labeling_order = WorkingLabelingOrder
            requestImageList.isTotalExplore = isTotalExplore ? 1 : 0
            // fast 탐색 버튼인 경우에는 라벨링 안한 것중에서 찾는다.
            if (fastSearch) {
                requestImageList.isTotalExplore = 0
            }

            requestImageList.prevNextFlag = FPNLFlag
            
            print("currentImageIndex = \(currentImageIndex), ImageList.count = \(ImageList.count)")
            
//            if (currentImageIndex >= 0 && currentImageIndex < ImageList.count && ImageList.count > 0) {
//                requestImageList.currentImageId = ImageList[currentImageIndex].id
//            }
//            else {
//                requestImageList.prevNextFlag = "F"
//                requestImageList.currentImageId = " "
//            }

            if (isFromSettingMenu) {
                if (IsReviewMode) {
                    if (WorkingImageIdOnReviewMode > " ") {
                        requestImageList.currentImageId = WorkingImageIdOnReviewMode
                        requestImageList.prevNextFlag = "L"
                    }
                    else {
                        requestImageList.currentImageId = " "
                        requestImageList.prevNextFlag = "L"
                    }
                }
                else {
                    if (WorkingImageId > " ") {
                        requestImageList.currentImageId = WorkingImageId
                    }
                    else {
                        requestImageList.currentImageId = " "
                        requestImageList.prevNextFlag = "F"
                    }
                }
            }
            else {
                if (IsReviewMode) {
                    if (WorkingImageIdOnReviewMode > " ") {
                        requestImageList.currentImageId = WorkingImageIdOnReviewMode
                    }
                    else {
                        requestImageList.currentImageId = " "
                        requestImageList.prevNextFlag = "F"
                    }
                }
                else {
                    if (WorkingImageId > " ") {
                        requestImageList.currentImageId = WorkingImageId
                    }
                    else {
                        requestImageList.currentImageId = " "
                        requestImageList.prevNextFlag = "F"
                    }
                }
            }
            

            requestImageList.isReviewMode = IsReviewMode ? 1 : 0

            if (IsReviewMode) {
                var labelIndexOnReviewMode = LabelIndexOnReviewMode();
                
                labelIndexOnReviewMode.target_cd = 0;
                labelIndexOnReviewMode.label_cd = LeftIndexOnReviewMode
                requestImageList.LabelIndexesOnReviewMode.append(labelIndexOnReviewMode);
                
                labelIndexOnReviewMode.target_cd = 1;
                labelIndexOnReviewMode.label_cd = RightIndexOnReviewMode
                requestImageList.LabelIndexesOnReviewMode.append(labelIndexOnReviewMode);
            }
            
            let jsonData = try? JSONEncoder().encode(requestImageList);
            
//            let jsonString = String(data: jsonData!, encoding: .utf8)
//            print(jsonString!)
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            //print("endpointUrl:\(endpointUrl)")
            
            // 요청할 최종 url 정의
            // -------------------------------------------------
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData
            

        case typeURLRequest.SaveLabelingResult:  // 라벨링 결과 저장
            
            struct LabelingLocationResult: Codable {
                var target_cd: Int?
                var label_cd: Int?
            }
            
            struct MarkResult: Codable {
                var type: Int?
                var shape: String?
            }
            
            struct RequestSaveLabelingResult: Codable {
                var proc_name: String?
                var project_cd: String?
                var user_id: String?
                var image_id: String?
                var labeling_ord: Int?
                var result: [LabelingLocationResult] = []
                var mark_result: [MarkResult] = []
            }
            
            var requestSaveLabelingResult = RequestSaveLabelingResult()
            requestSaveLabelingResult.proc_name = "P_SAVE_LABELING_RESULT2"
            requestSaveLabelingResult.project_cd = WorkingProjectCode
            requestSaveLabelingResult.user_id = LoginID
            requestSaveLabelingResult.labeling_ord = WorkingLabelingOrder
            requestSaveLabelingResult.image_id = self.imageIDLabel.text
            
            var labelingLocationResult = LabelingLocationResult();
            
            if (LabelList.getLabelCount(location: 0) > 0 && getLastSelectedIndex(0) >= 0) {
                labelingLocationResult.target_cd = 0;
                //labelingLocationResult.label_cd = getLastSelectedIndex(0);
                labelingLocationResult.label_cd = LabelList.getLabelCode(location: 0)[getLastSelectedIndex(0)];
                requestSaveLabelingResult.result.append(labelingLocationResult);
            }
            
            if (LabelList.getLabelCount(location: 1) > 0 && getLastSelectedIndex(1) >= 0) {
                labelingLocationResult.target_cd = 1;
                //labelingLocationResult.label_cd = getLastSelectedIndex(1);
                labelingLocationResult.label_cd = LabelList.getLabelCode(location: 1)[getLastSelectedIndex(1)];
                requestSaveLabelingResult.result.append(labelingLocationResult);
            }
            
            var markResult = MarkResult()
            for item in arrayMarkShapeLayer {
                markResult.type = item.type?.rawValue
                markResult.shape = shapeStingFormat(item)
                requestSaveLabelingResult.mark_result.append(markResult)
            }
            
            let jsonData = try? JSONEncoder().encode(requestSaveLabelingResult);
            
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            //print("endpointUrl:\(endpointUrl)")
            
            // 요청할 최종 url 정의
            // -------------------------------------------------
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData
            
        case typeURLRequest.DropImage:  // Drop 결과 저장
            
            struct RequestData: Codable {
                var proc_name: String?
                var project_cd: String?
                var user_id: String?
                var image_id: String?
                var labeling_ord: Int?
                var isDrop: String?
            }
            
            var requestData = RequestData()
            requestData.proc_name = "P_SAVE_DROP_RESULT"
            requestData.project_cd = WorkingProjectCode
            requestData.user_id = LoginID
            requestData.labeling_ord = WorkingLabelingOrder
            requestData.image_id = self.imageIDLabel.text
            requestData.isDrop = self.isDropSwitch.isOn ? "Y" : "N"
            
            let jsonData = try? JSONEncoder().encode(requestData);
            
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            //print("endpointUrl:\(endpointUrl)")
            
            // 요청할 최종 url 정의
            // -------------------------------------------------
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData
            
        case typeURLRequest.GetReferImageList:
            
            struct RequestReferImage: Codable {
                var proc_name: String?
                var project_cd: String?
                var image_id: String?
            }
            
            var requestReferImage = RequestReferImage();
            requestReferImage.proc_name = "P_GET_REFER_IMAGE_LIST"
            requestReferImage.project_cd = WorkingProjectCode
            requestReferImage.image_id = self.imageIDLabel.text
            //requestReferImage.image_id = "082900023_000001"   // test
            
            let jsonData = try? JSONEncoder().encode(requestReferImage);
            
            // 접속 server url 정의
            // -------------------------------------------------
            let endpoint = ILA4ML_URL_PROC
            guard let endpointUrl = URL(string: endpoint) else {
                print("URL Error : \(endpoint)")
                return nil
            }
            
            request = URLRequest(url: endpointUrl)
            request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request!.httpMethod = "POST"
            request!.httpBody = jsonData
            
        default:
            break
        }
        
        return request
        
    }
    
    func shapeStingFormat(_ markShape: MarkShape) -> String {
        var shapeString:String = ""
        if (markShape.type == MarkType.Ellipse) {
            let rect:CGRect = markShape.shape as! CGRect
            
            let realOrigin =
                CGPoint(x: (rect.origin.x - EditingImage.imageOrigin().x) / CGFloat(imageRealViewRatio!) ,
                        y: (rect.origin.y - EditingImage.imageOrigin().y) / CGFloat(imageRealViewRatio!) )
            let realSize = CGSize(width: rect.size.width / CGFloat(imageRealViewRatio!),
                                  height: rect.size.height / CGFloat(imageRealViewRatio!))
            shapeString = String(format: "%.0f,%.0f,%.0f,%.0f",
                                 realOrigin.x, realOrigin.y, realSize.width, realSize.height)
        }
        else if (markShape.type == MarkType.Polygon) {
            let points:[CGPoint] = markShape.shape as! [CGPoint]
            var start = true
            for point in points {
                let realOrigin = CGPoint(x: point.x - EditingImage.imageOrigin().x,
                                         y: point.y - EditingImage.imageOrigin().y)
                shapeString = shapeString + String(format: start ? "%.0f,%.0f" : ",%.0f,%.0f",
                                                   realOrigin.x, realOrigin.y)
                start = false
            }
        }
        return shapeString
    }
    
    // JSON 포맷 파싱
    // ==========================================================================
    func parseJson(parsingType:typeJsonParsing, jsonFormat:Dictionary<String, Any>?) -> AnyObject? {
        
        let returnAnyObject:Bool = false
        
        guard let json = jsonFormat else {
            print("func parseJson:jsonFormat is nil")
            return returnAnyObject as AnyObject
        }
        
        switch parsingType {
        case typeJsonParsing.Success:  // 성공여부 가져오기
            
            do {
                guard let success = json["success"] as? Bool else {
                    throw ResponseDataError.JsonProtocol
                }
                return success as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
                LastURLErrorMessage = error.rawValue
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
                LastURLErrorMessage = error.debugDescription
            }
            
        case typeJsonParsing.ErrorMessage:  //  에러 메시지 가져오기
            
            do {
                guard let errorMessage = json["err_msg"] as? String else {
                    throw ResponseDataError.JsonProtocol
                }
                return errorMessage as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.ErrorCode:  //  에러 코드 가져오기
            
            do {
                guard let errorCode = json["err_code"] as? Int else {
                    throw ResponseDataError.JsonProtocol
                }
                return errorCode as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.SaveLabelingResult:  //  저장 결과 회신 메시지에서 총건수와 완료건수 가져오기
            
            do {
                guard let total_count = json["total_count"] as? Int,
                    let complete_count = json["complete_count"] as? Int
                    else {
                        throw ResponseDataError.JsonProtocol
                }
                // 이미지 전체 갯수 및 완료 갯수 저장
                self.total_count = total_count
                self.complete_count = complete_count
                
                // 20190909 label list 추가. 저장 후 바로 라벨링 목록(라벨별 수량 포함)을 가져오기
                var labelList:[LabelInfo] = []
                
                // 하부 구조가 또 있으며 여러개가 있을 경우 대비 [[String: Any]], 하나일 경우 [String: Any]
                // ------------------------------------
                if let lList = json["label_list"] as? [[String: Any]] {
                    for lbl in lList {
                        guard let location:Int = lbl["target_cd"] as? Int,
                            let value:Int = lbl["label_cd"] as? Int,
                            let text:String = lbl["label_desc"] as? String
                            else { throw ResponseDataError.JsonProtocol }
                        
                        let label = LabelInfo()
                        label.location = location
                        label.value = value
                        label.text = text
                        labelList.append(label)
                    }
                }
                
                if (labelList.count > 0) {
                    LabelList.arrayLabelInfo = labelList
                }
                
                return complete_count as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.DropImage:  //  저장 결과 회신
            
            do {
                guard let isDrop = json["isDrop"] as? String,
                    let total_count = json["total_count"] as? Int,
                    let complete_count = json["complete_count"] as? Int
                    else {
                        throw ResponseDataError.JsonProtocol
                }
                
                // 이미지 전체 갯수 및 완료 갯수 저장
                self.total_count = total_count
                self.complete_count = complete_count

                return isDrop as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.GetLabelList:  // 라벨 목록
            do {
                
                var labelList:[LabelInfo] = []
                
                // 하부 구조가 또 있으며 여러개가 있을 경우 대비 [[String: Any]], 하나일 경우 [String: Any]
                // ------------------------------------
                if let items = json["label_list"] as? [[String: Any]] {
                    for item in items {
                        //print("item:", item)
                        
                        guard let location:Int = item["target_cd"] as? Int,
                            let value:Int = item["label_cd"] as? Int,
                            let text:String = item["label_desc"] as? String
                            else { throw ResponseDataError.JsonProtocol }
                        
                        let label = LabelInfo()
                        label.location = location
                        label.value = value
                        label.text = text
                        labelList.append(label)
                    }
                }
                else {
                    print("typeJsonParsing.GetLabelList else")
                    throw ResponseDataError.JsonProtocol
                }
                
                return labelList as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.GetLabelListWithResult:  // 라벨 목록(라벨링 결과 포함)
            do {
                
                var labelList:[LabelInfo] = []
                
                // 하부 구조가 또 있으며 여러개가 있을 경우 대비 [[String: Any]], 하나일 경우 [String: Any]
                // ------------------------------------
                if let items = json["label_list"] as? [[String: Any]] {
                    for item in items {
                        //print("item:", item)
                        
                        guard let location:Int = item["target_cd"] as? Int,
                            let value:Int = item["label_cd"] as? Int,
                            let text:String = item["label_desc"] as? String
                            else { throw ResponseDataError.JsonProtocol }
                        
                        let label = LabelInfo()
                        label.location = location
                        label.value = value
                        label.text = text
                        labelList.append(label)
                    }
                }
                else {
                    print("typeJsonParsing.GetLabelList else")
                    throw ResponseDataError.JsonProtocol
                }
                
                return labelList as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.GetImageInfo:  // 이미지 정보
            do {
                
                let imageInfo:ImageInfo = ImageInfo()
                
                guard let id = json["image_id"] as? String,
                    let serverLocation = json["server_location"] as? String,
                    let name = json["pi_name"] as? String,
                    let age = json["pi_age"] as? Float,
                    let sex = json["pi_sex"] as? String
                else {
                    throw ResponseDataError.JsonProtocol
                }
                
                imageInfo.id = id
                imageInfo.serverLocation = serverLocation
                imageInfo.name = name
                imageInfo.age = age
                imageInfo.sex = sex
                
                return imageInfo as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.GetImageList:  // 이미지 목록
            do {
                
                var imageList:[ImageInfo] = []
                
                // 하부 구조가 또 있으며 여러개가 있을 경우 대비 [[String: Any]], 하나일 경우 [String: Any]
                // ------------------------------------
                if let items = json["image_list"] as? [[String: Any]] {
                    for item in items {
                        //print("item:", item)
                        
                        guard let id = item["image_id"] as? String,
                            let serverLocation = item["server_location"] as? String,
                            let name = item["pi_name"] as? String,
                            let age = item["pi_age"] as? Float,
                            let sex = item["pi_sex"] as? String
                            else { throw ResponseDataError.JsonProtocol }
                        
                        let image = ImageInfo()
                        image.id = id
                        image.serverLocation = serverLocation
                        image.name = name
                        image.age = age
                        image.sex = sex
                        image.isLabelingDone = false    // 기본값 false, 아래에서 결과가 있으면 true로 변경
                        
                        if let labelingResults = item["labeling_result"] as? [[String: Any]] {
                            for labelingResult in labelingResults {
                                guard let target_cd = labelingResult["target_cd"] as? Int,
                                    let label_cd = labelingResult["label_cd"] as? Int
                                    else { throw ResponseDataError.JsonProtocol }
                                let labeling:LabelingLocationResult = LabelingLocationResult()
                                labeling.target_cd = target_cd
                                labeling.label_cd = label_cd
                                image.labelingResult.append(labeling)
                                image.isLabelingDone = true
                            }
                        }
                        
                        if let markResults = item["mark_result"] as? [[String: Any]] {
                            for markResult in markResults {
                                guard let type = markResult["type"] as? Int,
                                    let shape = markResult["shape"] as? String
                                    else { throw ResponseDataError.JsonProtocol }
                                let mark:MarkResult = MarkResult()
                                if (type == 0) {
                                    mark.type = MarkType.Ellipse
                                    mark.shape = shape
                                    image.markResult.append(mark)
                                }
                                else if (type == 1) {
                                    mark.type = MarkType.Polygon
                                    mark.shape = shape
                                    image.markResult.append(mark)
                                }
                                else {
                                    // 아무것도 하지 않음
                                }
                            }
                        }
                        
                        imageList.append(image)
                        
                    }
                }
                else {
                    print("typeJsonParsing.GetImageList else")
                    throw ResponseDataError.JsonProtocol
                }
                
                return imageList as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.GetImageOne:  // 이미지 목록 랜덤하게 하나
            do {
                
                var imageList:[ImageInfo] = []
                
                // 하부 구조가 또 있으며 여러개가 있을 경우 대비 [[String: Any]], 하나일 경우 [String: Any]
                // ------------------------------------
                if let items = json["image_list"] as? [[String: Any]] {
                    for item in items {
                        //print("item:", item)
                        
                        guard let id = item["image_id"] as? String,
                            let serverLocation = item["server_location"] as? String,
                            let name = item["pi_name"] as? String,
                            let age = item["pi_age"] as? Float,
                            let sex = item["pi_sex"] as? String,
                            let total_count = item["total_count"] as? Int,
                            let complete_count = item["complete_count"] as? Int,
                            let more_image = item["more_image"] as? String,
                            let isDrop = item["isDrop"] as? String
                            else { throw ResponseDataError.JsonProtocol }
                        
                        let image = ImageInfo()
                        image.id = id
                        image.serverLocation = serverLocation
                        image.name = name
                        image.age = age
                        image.sex = sex
                        image.isDrop = isDrop
                        image.isLabelingDone = false    // 기본값 false, 아래에서 결과가 있으면 true로 변경
                        
                        // 이미지 전체 갯수 및 완료 갯수 저장
                        self.total_count = total_count
                        self.complete_count = complete_count
                        self.more_image = more_image
                        
                        if let labelingResults = item["labeling_result"] as? [[String: Any]] {
                            for labelingResult in labelingResults {
                                guard let target_cd = labelingResult["target_cd"] as? Int,
                                    let label_cd = labelingResult["label_cd"] as? Int
                                    else { throw ResponseDataError.JsonProtocol }
                                let labeling:LabelingLocationResult = LabelingLocationResult()
                                labeling.target_cd = target_cd
                                labeling.label_cd = label_cd
                                image.labelingResult.append(labeling)
                                image.isLabelingDone = true
                            }
                        }

//                        // 20190604 label list 추가
                        var labelList:[LabelInfo] = []
                        
                        // 하부 구조가 또 있으며 여러개가 있을 경우 대비 [[String: Any]], 하나일 경우 [String: Any]
                        // ------------------------------------
                        if let lList = item["label_list"] as? [[String: Any]] {
                            for lbl in lList {
                                guard let location:Int = lbl["target_cd"] as? Int,
                                    let value:Int = lbl["label_cd"] as? Int,
                                    let text:String = lbl["label_desc"] as? String
                                    else { throw ResponseDataError.JsonProtocol }
                                
                                let label = LabelInfo()
                                label.location = location
                                label.value = value
                                label.text = text
                                labelList.append(label)
                            }
                        }
                        
                        if (labelList.count > 0) {
                            LabelList.arrayLabelInfo = labelList
                        }
                        
                        
                        if let markResults = item["mark_result"] as? [[String: Any]] {
                            for markResult in markResults {
                                guard let type = markResult["type"] as? Int,
                                    let shape = markResult["shape"] as? String
                                    else { throw ResponseDataError.JsonProtocol }
                                let mark:MarkResult = MarkResult()
                                if (type == 0) {
                                    mark.type = MarkType.Ellipse
                                    mark.shape = shape
                                    image.markResult.append(mark)
                                }
                                else if (type == 1) {
                                    mark.type = MarkType.Polygon
                                    mark.shape = shape
                                    image.markResult.append(mark)
                                }
                                else {
                                    // 아무것도 하지 않음
                                }
                            }
                        }
                        
                        imageList.append(image)
                    }
                }
                else {
                    print("typeJsonParsing.GetImageImageOne else")
                    throw ResponseDataError.JsonProtocol
                }
                
                return imageList as AnyObject
                
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }
            
        case typeJsonParsing.GetReferImageList:
            do {
                guard let imgList = json["refer_image_list"] as? [String]
                    else {
                        print("typeJsonParsing.GetLabelList else")
                        throw ResponseDataError.JsonProtocol
                }
                return imgList as AnyObject
            }
            catch let error as ResponseDataError {
                print("[ResponseDataError] \(error.rawValue)")
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
            }

        default:
            break
        }
        
        return returnAnyObject as AnyObject
        
    }

}

