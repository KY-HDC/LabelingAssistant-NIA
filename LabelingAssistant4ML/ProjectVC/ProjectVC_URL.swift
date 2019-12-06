//
//  ProjectVC_URL.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 05/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

class ProjectInfo {
    var code:String?                    // 프로젝트 코드
    var name:String?                    // 프로젝트 명
    var labeling_times:Int?             // 라벨링 차수
    var image_dir:String?               // 이미지 위치
    var labeling_ord:Int?               // 최종(진행중) 라벨링 차수
    var begin_dt:String?                // 라벨링 시작 일자
    var end_dt:String?                  // 라벨링 종료 일자
    var total_num:Int?                  // 전체 대상 개수
    var complete_num:Int?               // 완료 개수
    var working:Bool?                   // 작업중 여부
    var last_image_id:String?         // 마지막 저장된 이미지 id
    var cur_image_id:String?          // 마지막 조회된 이미지 id
}

extension ProjectVC {

    enum typeURLRequest:Int {
        case GetProjectList = 0, ProjectBeginEnd, End
    }
    
    enum typeJsonParsing:Int {
        case GetProjectList, ProjectBeginEnd, Success, ErrorMessage, End
    }
    
    // 라벨링 시작/종료 저장
    // ==========================================================================
    func projectBeginEnd() -> Bool {
        // ------------------------------------------------
        let requestURL = makeURLRequestForJsonFromServer(requestType: .ProjectBeginEnd)
        var isDownloaded = false
        var result = false

        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.beginend")
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
        case typeURLRequest.ProjectBeginEnd:  // 프로젝트 라벨링 시작 종료
            
            struct RequestProjectBeginEnd: Codable {
                var proc_name: String?
                var project_cd: String?
                var user_id: String?
                var type: String?
                var labeling_ord: Int?
            }
            
            var projectBeginEnd = RequestProjectBeginEnd();
            projectBeginEnd.proc_name = "P_LABELING_BEGIN_END"
            projectBeginEnd.type = beginEndType.rawValue
            projectBeginEnd.user_id = LoginID
            if (beginEndType == enumBeginEndType.End) {
                projectBeginEnd.project_cd = ""
                projectBeginEnd.labeling_ord = 0
            }
            else {
                projectBeginEnd.project_cd = selectedProjectInfo.code
                projectBeginEnd.labeling_ord = selectedProjectInfo.labeling_ord
//                projectBeginEnd.project_cd = ProjectList[selectedProjectIndex].code
//                projectBeginEnd.labeling_ord = ProjectList[selectedProjectIndex].labeling_ord
            }
            
            let jsonData = try? JSONEncoder().encode(projectBeginEnd);
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
        default:
            break
        }
        
        return returnAnyObject as AnyObject
        
    }
    
}
