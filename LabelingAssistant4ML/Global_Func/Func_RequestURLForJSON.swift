//
//  Func_RequestURLForJSON.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 14/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

enum RequestURLError: String, Error {
    case URLRequest = "RequestURLError: URLRequest error"
    case URLSession = "RequestURLError: URLSession error"
    case URLSessionData = "RequestURLError: URLSession Data error"
    case HTTPURLResponse = "RequestURLError: HTTPURLResponse error"
    case JsonConversion = "RequestURLError: JsonConversion error"
    case Unknown = "RequestURLError: Unknown error"
}

//kCFURLErrorUnknown   = -998,
//kCFURLErrorCancelled = -999,
//kCFURLErrorBadURL    = -1000,
//kCFURLErrorTimedOut  = -1001,
//kCFURLErrorUnsupportedURL = -1002,
//kCFURLErrorCannotFindHost = -1003,
//kCFURLErrorCannotConnectToHost    = -1004,
//kCFURLErrorNetworkConnectionLost  = -1005,
//kCFURLErrorDNSLookupFailed        = -1006,
//kCFURLErrorHTTPTooManyRedirects   = -1007,
//kCFURLErrorResourceUnavailable    = -1008,
//kCFURLErrorNotConnectedToInternet = -1009,
//kCFURLErrorRedirectToNonExistentLocation = -1010,
//kCFURLErrorBadServerResponse             = -1011,
//kCFURLErrorUserCancelledAuthentication   = -1012,
//kCFURLErrorUserAuthenticationRequired    = -1013,
//kCFURLErrorZeroByteResource        = -1014,
//kCFURLErrorCannotDecodeRawData     = -1015,
//kCFURLErrorCannotDecodeContentData = -1016,
//kCFURLErrorCannotParseResponse     = -1017,
//kCFURLErrorInternationalRoamingOff = -1018,
//kCFURLErrorCallIsActive               = -1019,
//kCFURLErrorDataNotAllowed             = -1020,
//kCFURLErrorRequestBodyStreamExhausted = -1021,
//kCFURLErrorFileDoesNotExist           = -1100,
//kCFURLErrorFileIsDirectory            = -1101,
//kCFURLErrorNoPermissionsToReadFile    = -1102,
//kCFURLErrorDataLengthExceedsMaximum   = -1103,

// 서버로부터 JSON 포맷으로 응답을 받기 위한 URL 요청과 응답시 콜백 처리
// =========================================================================
func RequestURLForJSON(requestURL:URLRequest?, completion: @escaping ((_ success:Bool,_ error:RequestURLError?,_ err_code:Int?,_ err_msg:String?, _ jsonFromServer:Dictionary<String, Any>?)->())) {
    
    // 디버그 창에 요청 내용 출력
    if let req = requestURL {
        print("--------------- requestURL --------------------------------------------")
        print(req)
        if let body = req.httpBody {
            print(NSString(data: body, encoding: String.Encoding.utf8.rawValue)!)
        }
        print("-----------------------------------------------------------------------")
    }
    
    var isRequestComplted:Bool = false
    var ok:Bool = false
    var reqUrlError:RequestURLError?
    var err_code:Int = 0
    var err_msg:String? = nil
    var json = Dictionary<String, Any>()
    
    // URL에 실제 접속 및 응답 처리용 콜백 정의
    // -------------------------------------------------
    guard let request = requestURL else {
        completion(false, RequestURLError.URLRequest, err_code, err_msg, nil)
        return
    }

    var endlessLoop = true
    var reqCount = 0
    
    var task:URLSessionDataTask

    while (endlessLoop) {

        reqCount = reqCount + 1
        print("--------------- count : \(reqCount)")

        task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                // 기본적인 네트워크 에러 처리
                // -------------------------------------------------
                
                guard error == nil else {
                    print("RequestURLError=URLSession.shared.dataTask:[[\(error.debugDescription)]]")
                    let err = error as NSError?
                    err_code = err!.code
                    err_msg = err?.localizedDescription
                    // cancel일 경우
                    throw RequestURLError.URLSession
                }
                
                guard let data = data else {
                    print("RequestURLError=[\(error.debugDescription)]")
                    throw RequestURLError.URLSessionData
                }
                
                //            guard let data = data, error == nil else {
                //                //print("RequestURLError=URLSession.shared.dataTask:[[\(error.debugDescription)]]")
                //                print("RequestURLError=URLSession.shared.dataTask:[[\(error)]]")
                //                throw RequestURLError.URLSession
                //            }
                
                // http 응답 상태 체크
                // -------------------------------------------------
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                    throw RequestURLError.HTTPURLResponse
                }
                
                // 대괄호로 묶여 올경우에는 배열(Array<Any>)로 받아서 첫번째 인자를 추출하여 사용
                // -------------------------------------------------
                if let responseJSON = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? Array<Any> {
                    // 대괄호로 묶인 JSON 포맷이라 첫번째를 추출하는 방식으로 해야 함
                    // ------------------------------------
                    json = responseJSON.first as! Dictionary<String, Any>
                }
                else {
                    // 대괄호 없이 처음부터 JSON 포맷으로 올경우 Dictionary<String,Any>로 받아서 사용
                    // -------------------------------------------------
                    if let responseJSON = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? Dictionary<String,Any> {
                        json = responseJSON
                    }
                    else {
                        throw RequestURLError.JsonConversion
                    }
                }
                
                //print(json)
                
                ok = true
                
                //completion(ok, reqUrlError, err_code, err_msg, json)
                //completion(true, nil, err_code, err_msg, json)
            }
            catch let error as RequestURLError {
                print("[RequestURLError] \(error.rawValue)")
                ok = false
                reqUrlError = error
                //completion(false, error, err_code, err_msg, nil)
                //completion(ok, reqUrlError, err_code, err_msg, json)
            }
            catch let error as NSError {
                print("[NSError  ] \(error.debugDescription)")
                ok = false
                reqUrlError = RequestURLError.Unknown
                err_code = error.code
                err_msg = error.localizedDescription
                //completion(ok, reqUrlError, err_code, err_msg, json)
                //completion(false, RequestURLError.Unknown, err_code, err_msg, nil)
            }
            isRequestComplted = true
        }
        
        isRequestComplted = false
        ok = false
        reqUrlError = nil
        err_code = 0
        err_msg = nil

        task.resume()

        // task status
        // 0 : runnung, 1 : suspended, 2:canceling, 3:completed
        
        // 일정 시간(초)동안 기다림
        for i in 1...RequestURLTimeout {
            if (isRequestComplted == true) {
                break
            }
            DoEvents(f: 0.1)
            print("waiting time : \(i*100) msec")
        }
        
        // 기다렸는데도 아직 실행 중이면 cancel
        if (isRequestComplted == false) {
            print("--------------- try cancel request")
            ok = false
            reqUrlError = RequestURLError.URLSession
            err_code = -1
            err_msg = "인터넷 연결 등의 문제로 시간이 초과되었습니다.\r\n잠시 후 재시도 바랍니다.\r\n문제가 지속적인 경우 관리자게 문의 바랍니다."
            task.cancel()
            endlessLoop = false
        }
        else {
            // CannotConnectToHost, NetworkConnectionLost, NotConnectedToInternet인 경우 잠시 쉬었다가 재시도
            // 그렇지 않은 경우에는 종료
            if (err_code == -1004 || err_code == -1005 || err_code == -1009 ) {
                DoEvents(f: 0.5)
            }
            else {
                endlessLoop = false
            }
        }

        // 3번까지 재시도 했으면 종료
        if reqCount >= 3 {
            endlessLoop = false
        }
    }

    print("--------------- result")
    print("ok=\(ok)")
    print("reqUrlError=\(reqUrlError)")
    print("err_code=\(err_code)")
    switch err_code {
    case -1001:
        err_msg = "인터넷 등의 문제로 시간이 초과되었습니다.\r\n관리자에게 문의 바랍니다."
    case -1003:
        err_msg = "서버 주소를 찾을 수 없습니다.\r\n서버 주소를 확인해 주세요"
    case -1004:
        err_msg = "서버에 접속을 할 수 없습니다.\r\n인터넷 연결 상태 확인 또는 관리자에게 문의 바랍니다."
    case -1005:
        err_msg = "네트워크 상태가 불안정합니다.\r\n잠시 후 재시도 바랍니다."
    case -1009:
        err_msg = "인터넷(WIFI) 연결을 확인해 주세요."
    default:
        break
    }
    print("err_msg=\(err_msg)")
    print("json=\(json)")

    print("--------------- requestURL End ----------------------------------------")
    completion(ok, reqUrlError, err_code, err_msg, json)

}

