//
//  SlideReferImagesVC_URL.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 29/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

extension SlideReferImagesVC {
    
    enum typeURLRequest:Int {
        case GetReferImageList = 0, End
    }
    
    enum typeJsonParsing:Int {
        case GetReferImageList, Success, ErrorMessage, End
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
        case typeURLRequest.GetReferImageList:
            
            struct RequestReferImage: Codable {
                var proc_name: String?
                var project_cd: String?
                var image_id: String?
            }
            
            var requestReferImage = RequestReferImage();
            requestReferImage.proc_name = "P_GET_REFER_IMAGE_LIST"
            requestReferImage.project_cd = projectCode
            requestReferImage.image_id = imageId
            requestReferImage.image_id = "082900023_000001"   // test
            
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
