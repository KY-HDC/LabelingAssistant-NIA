//
//  LoginVC_URL.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 06/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

extension LoginVC {

    enum typeURLRequest:Int {
        case Login = 0, End
    }
    
    enum typeJsonParsing:Int {
        case Login, Success, ErrorMessage, End
    }

    // 로그인 체크
    // ==========================================================================
    func login() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .Login)
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.login")
        LastURLErrorMessage = ""

        RequestURLForJSON(requestURL: requestURL) { success, error, err_code, err_msg, json in
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
                        else {
                            throw ResponseDataError.JsonParsing
                    }
                    
                    if (!getSuccess) {
                        guard let msg:String =
                            self.parseJson(parsingType: .ErrorMessage, jsonFormat: json) as? String
                            else { throw ResponseDataError.JsonParsing }
                        
                        LastURLErrorMessage = msg
                        
                        throw ResponseDataError.ReturnValue
                    }
                    
                    print("---------------------------------")
                    guard let loginName:String =
                        self.parseJson(parsingType: .Login, jsonFormat: json) as? String
                        else { throw ResponseDataError.JsonParsing }
                    
                    LoginName = loginName
                    
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
            print("[ResponseDataError] \(ResponseDataError.Timeout.rawValue)")
        }

        return result
    }
    
    
    // 서버로부터 json 포맷으로 받기 위한 url request 생성하기
    // ==========================================================================
    func makeURLRequestForJsonFromServer(requestType:typeURLRequest) -> URLRequest? {
        
        var request:URLRequest? = nil
        
        switch requestType {
        case typeURLRequest.Login:  // 로그인
            
            LoginID = LoginIDText.text!
            
            struct RequestLoginInfo: Codable {
                var proc_name: String?
                var user_id: String?
                var passwd: String?
            }
            
            var requestLoginInfo = RequestLoginInfo();
            requestLoginInfo.proc_name = "P_LOGIN"
            requestLoginInfo.user_id = LoginID
            requestLoginInfo.passwd = PasswordText.text
            
            let jsonData = try? JSONEncoder().encode(requestLoginInfo);
            
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
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
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
        case typeJsonParsing.Login:  // 로그인
            do {
                
                guard let userName = json["user_nm"] as? String else {
                    throw ResponseDataError.JsonProtocol
                }
                return userName as AnyObject
                
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
