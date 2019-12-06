//
//  Classs_UserDefaults.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 30/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

class MyUserDefaults {

    func getUserDefaults() {
        
        // user default value 가져오기

        if let addr = UserDefaults.standard.string(forKey: DefaultKey_ServerAddress) {
            SetServerAddress(addr)
        }
        
        isLogin = UserDefaults.standard.bool(forKey: DefaultKey_isLogin)
        
        LoginID = ""
        LoginName = "Not signed."
        
        if let id = UserDefaults.standard.string(forKey: DefaultKey_loginId) {
            LoginID = id
        }
        if (isLogin) {
            if let name = UserDefaults.standard.string(forKey: DefaultKey_loginName) {
                LoginName = name
            }
        }
        
        print("getUserDefault : ", LoginName)
        
        isWorking = UserDefaults.standard.bool(forKey: DefaultKey_isWorking)
        
        //PostNoti(noti: EnumMyNoti.LoginOutEvent)
        
        WorkingProjectCode = ""
        WorkingProjectName = "프로젝트 미설정"
        WorkingLabelingOrder = 0
        WorkingImageIndex = 0
        WorkingImageId = ""
        LastLabelingImageId = ""

        if (isWorking) {
            if let code = UserDefaults.standard.string(forKey: DefaultKey_ProjectCode) {
                WorkingProjectCode = code
            }
            if let name = UserDefaults.standard.string(forKey: DefaultKey_ProjectName) {
                WorkingProjectName = name
            }
            WorkingLabelingOrder = UserDefaults.standard.integer(forKey: DefaultKey_LabelingOrder)
            WorkingImageIndex = UserDefaults.standard.integer(forKey: DefaultKey_ImageIndex)
            
            // 작업중이었던 이미지 id
            // ------------------------------------------------------------------------
            if let workingImageId = UserDefaults.standard.string(forKey: DefaultKey_ImageId) {
                WorkingImageId = workingImageId
            }
            
            // 마지막 라벨링 이미지 id
            // ------------------------------------------------------------------------
            if let lastLabelingImageId = UserDefaults.standard.string(forKey: DefaultKey_LastLabelingImageId) {
                LastLabelingImageId = lastLabelingImageId
            }

        }
        if (isLogin) {
            let rp = RequestProject()
            if (rp.projectList()) {
                setWorkingProjectInfo(isNotiPost: true)
            }
            else {
                var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
                topWindow?.rootViewController = UIViewController()
                topWindow?.windowLevel = UIWindow.Level.alert + 1
                let alert: UIAlertController = UIAlertController(title: "메세지 확인", message: LastURLErrorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "확인", style: .default, handler: {(alertAction) in
                    topWindow?.isHidden = true
                    topWindow = nil
                }))
                topWindow?.makeKeyAndVisible()
                topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // ---------------------------------------------------------------------
    // 현재 프로젝트 및 차수 정보 세팅 및 저장
    // ---------------------------------------------------------------------
    func setWorkingProjectInfo(isNotiPost: Bool) {
        
        isWorking = false
        
        for project in ProjectList {
            if (project.working!) {
                isWorking = true
                WorkingProjectCode = project.code!
                WorkingProjectName = project.name!
                WorkingLabelingOrder = project.labeling_ord!
                WorkingImageIndex = 0
                WorkingImageId = project.cur_image_id!
                LastLabelingImageId = project.last_image_id!
                break;
            }
        }
        
        UserDefaults.standard.set(isWorking, forKey: DefaultKey_isWorking)
        UserDefaults.standard.set(WorkingProjectCode, forKey: DefaultKey_ProjectCode)
        UserDefaults.standard.set(WorkingProjectName, forKey: DefaultKey_ProjectName)
        UserDefaults.standard.set(WorkingLabelingOrder, forKey: DefaultKey_LabelingOrder)
        UserDefaults.standard.set(WorkingImageIndex, forKey: DefaultKey_ImageIndex)
        UserDefaults.standard.set(WorkingImageId, forKey: DefaultKey_ImageId)
        UserDefaults.standard.set(LastLabelingImageId, forKey: DefaultKey_LastLabelingImageId)

        if (isNotiPost) {
            //PostNoti(noti: EnumMyNoti.LabelingBeginEndEvent)
        }
    }

}
