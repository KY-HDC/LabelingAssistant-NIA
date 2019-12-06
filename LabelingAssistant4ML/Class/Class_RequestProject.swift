//
//  Class_RequestProject.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 30/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

class RequestProject: NSObject {

    enum typeJsonParsing:Int {
        case GetProjectList, Success, ErrorMessage, End
    }
    
    // 서버로부터 프로젝트 목록 가져오기
    // ==========================================================================
    public func projectList() -> Bool {
        
        struct RequestProjectInfo: Codable {
            var proc_name: String?
            var user_id: String?
        }
        
        var requestProjectInfo = RequestProjectInfo();
        requestProjectInfo.proc_name = "P_GET_PROJECT_LIST2"
        requestProjectInfo.user_id = LoginID
        
        let jsonData = try? JSONEncoder().encode(requestProjectInfo);
        //let jsonString = String(data: jsonData!, encoding: .utf8)
        //print(jsonString!)
        
        // 접속 server url 정의
        // -------------------------------------------------
        let endpoint = ILA4ML_URL_PROC
        guard let endpointUrl = URL(string: endpoint) else {
            print("URL Error : \(endpoint)")
            return false
        }
        
        // 요청할 최종 url 정의
        // -------------------------------------------------
        var requestURL = URLRequest(url: endpointUrl)
        requestURL.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        requestURL.httpMethod = "POST"
        requestURL.httpBody = jsonData
        
        var isDownloaded = false
        var result = false
        
        let queueURL = DispatchQueue(label: "kr.ubizit.queueURL.projectlist")
        
        RequestURLForJSON(requestURL: requestURL) { success, error,  err_code, err_msg, json in
            queueURL.async {
                do {
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
                    
                    guard let pList:[ProjectInfo] =
                        self.parseJson(parsingType: .GetProjectList, jsonFormat: json) as? [ProjectInfo]
                        else { throw ResponseDataError.JsonParsing }
                    
                    ProjectList = pList
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
        }
        
        return result
    }
    
    
    // JSON 포맷 파싱
    // ==========================================================================
    private func parseJson(parsingType:typeJsonParsing, jsonFormat:Dictionary<String, Any>?) -> AnyObject? {
        
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

        case typeJsonParsing.GetProjectList:  // 프로젝트 목록
            do {
                
                var projectList:[ProjectInfo] = []
                
                // 하부 구조가 또 있으며 여러개가 있을 경우 대비 [[String: Any]], 하나일 경우 [String: Any]
                // ------------------------------------
                if let items = json["project_list"] as? [[String: Any]] {
                    for item in items {
                        //print("item:", item)
                        
                        guard let code:String = item["project_cd"] as? String,
                            let name:String = item["project_nm"] as? String,
                            let labeling_times:Int = item["labeling_times"] as? Int,
                            let image_dir:String = item["image_dir"] as? String,
                            let labeling_ord:Int = item["labeling_ord"] as? Int,
                            let begin_dt:String = item["begin_dt"] as? String,
                            let end_dt:String = item["end_dt"] as? String,
                            let total_num:Int = item["total_num"] as? Int,
                            let complete_num:Int = item["complete_num"] as? Int,
                            let last_image_id:String = item["last_image_id"] as? String,
                            let cur_image_id:String = item["cur_image_id"] as? String,
                            let working:Bool = item["working"] as? Bool
                            else { throw ResponseDataError.JsonProtocol }
                        
                        let project = ProjectInfo()
                        project.code = code
                        project.name = name
                        project.labeling_times = labeling_times
                        project.image_dir = image_dir
                        project.labeling_ord = labeling_ord
                        project.begin_dt = begin_dt
                        project.end_dt = end_dt
                        project.total_num = total_num
                        project.complete_num = complete_num
                        project.last_image_id = last_image_id
                        project.cur_image_id = cur_image_id
                        project.working = working
                        projectList.append(project)
                    }
                }
                else {
                    print("typeJsonParsing.GetLabelList else")
                    throw ResponseDataError.JsonProtocol
                }
                
                return projectList as AnyObject
                
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
