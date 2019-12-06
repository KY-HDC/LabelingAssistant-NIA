//
//  LoginVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 02/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

// user defualt key 정의
// ==============================================================================
let DefaultKey_ServerAddress = "ServerAddress"
let DefaultKey_isLogin = "isLogin"
let DefaultKey_loginId = "LoginID"
let DefaultKey_loginName = "LoginName"

// login 정보 글로벌 정의
// ==============================================================================
var isLogin = false;
var LoginID = ""
var LoginName = ""

class LoginVC: UIViewController {

    @IBOutlet var myNaviBar: UINavigationBar!
    
    //@IBOutlet var tableViewLogin: UITableView!
    @IBOutlet var serverAddress: UITextField!
    @IBOutlet var loginIDTitleLabel: UILabel!
    @IBOutlet var loginNameTitleLabel: UILabel!
    @IBOutlet var passwordTitleLabel: UILabel!
    @IBOutlet var LoginIDText: UITextField!
    @IBOutlet var LoginNameText: UITextField!
    @IBOutlet var PasswordText: UITextField!
    @IBOutlet var ConfirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "로그인/로그아웃"

        ConfirmButton.setRounded()
        initContents()
    }
    
    var errorMessage: String = "No Error!"
    
    @IBAction func ConfirmButtonTapped(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if (isLogin) {
            let dialogMessage = UIAlertController(title: "확인", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "예", style: .destructive, handler: { (action) -> Void in
                self.logOut()
            })
            let cancel = UIAlertAction(title: "아니오", style: .cancel) { (action) -> Void in
            }
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
        }
        else {
            
            SetServerAddress(serverAddress.text!)
            
            // ------------------------------------------------
            // 진행중 메세지 표시
            // ------------------------------------------------
            let alertProgressNoAction = UIAlertController(title: "로그인 중...\n\n\n", message: nil, preferredStyle: .alert)
            let spinnerIndicator = UIActivityIndicatorView(style: .whiteLarge)
            spinnerIndicator.center = CGPoint(x: 135.0, y: 85.5)
            spinnerIndicator.color = UIColor.black
            spinnerIndicator.startAnimating()
            alertProgressNoAction.view.addSubview(spinnerIndicator)
            self.present(alertProgressNoAction, animated: false, completion: nil)

            let success = login()
            if (success) {
                isLogin = true
                print("------- Log in : ", isLogin)
                alertProgressNoAction.dismiss(animated: false, completion: nil)
            }
            else {
                isLogin = false
                print("------- Log in error : ", isLogin)
                spinnerIndicator.removeFromSuperview()
                let otherAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                    alertProgressNoAction.dismiss(animated: true, completion: nil)
                })
                alertProgressNoAction.title = "로그인 실패!\n\n\(LastURLErrorMessage)\n\n"
                alertProgressNoAction.addAction(otherAction)
            }
            
            logInOut()
        }
    }
    
    func logOut() {
        isLogin = false
        print("------- Log out : ", isLogin)
        logInOut()
    }
    
    func initContents() {
        serverAddress.text = ServerAddress
        LoginIDText.text = LoginID
        LoginNameText.isEnabled = false

        if (isLogin) {
            loginIDTitleLabel.text = "로그인 ID"
            
            loginNameTitleLabel.isHidden = false
            LoginNameText.isHidden = false
            
            LoginNameText.text = LoginName
            ConfirmButton.setTitle("Log out", for: .normal)
            passwordTitleLabel.isHidden = true
            PasswordText.isHidden = true
            PasswordText.text = ""
            
            serverAddress.isEnabled = false
            LoginIDText.isEnabled = false
        }
        else {
            loginIDTitleLabel.text = "로그인 ID"
            
            loginNameTitleLabel.isHidden = true
            LoginNameText.isHidden = true
            
            LoginNameText.text = ""
            ConfirmButton.setTitle("Log in", for: .normal)
            passwordTitleLabel.isHidden = false
            PasswordText.isHidden = false
            PasswordText.text = ""

            serverAddress.isEnabled = true
            LoginIDText.isEnabled = true
        }
    }
    
    func logInOut() {

        if (isLogin) {
            // 로그인 정보
            UserDefaults.standard.set(true, forKey: DefaultKey_isLogin)
            UserDefaults.standard.set(LoginID, forKey: DefaultKey_loginId)
            UserDefaults.standard.set(LoginName, forKey: DefaultKey_loginName)
        }
        else {
            LoginName = "Not signed."
            UserDefaults.standard.set(false, forKey: DefaultKey_isLogin)
            UserDefaults.standard.removeObject(forKey: DefaultKey_loginName)
        }
        initContents()
        
        //PostNoti(noti: EnumMyNoti.LoginOutEvent)

        // login이면 기존 프로젝트 정보 클리어 및 새로 요청
        if (isLogin) {
            clearProject()
            let rp = RequestProject()
            if (rp.projectList()) {
                let ud = MyUserDefaults()
                ud.setWorkingProjectInfo(isNotiPost: true)

                // 로그인 창을 닫는다.
                if (isWorking) {
                    performSegue(withIdentifier: "unwindFromNewLogin", sender: self)
                }
                else {
                    performSegue(withIdentifier: "unwindFromNewLogin", sender: self)
                }
            }
        }
    }
    
    func clearProject() {
        // 전역 리스트 변수 내용 제거
        ProjectList.removeAll()
        ImageList.removeAll()
        LabelList.arrayLabelInfo.removeAll()
        
        // 전역 변수 초기화
        isWorking = false
        WorkingProjectCode = ""
        WorkingProjectName = "프로젝트 선택되지 않음"
        WorkingLabelingOrder = 0
        WorkingImageIndex = 0
        WorkingImageId = ""
        LastLabelingImageId = ""

        // 유저디폴트 초기화
        UserDefaults.standard.set(isWorking, forKey: DefaultKey_isWorking)
        UserDefaults.standard.removeObject(forKey: DefaultKey_ProjectCode)
        UserDefaults.standard.removeObject(forKey: DefaultKey_ProjectName)
        UserDefaults.standard.removeObject(forKey: DefaultKey_LabelingOrder)
        UserDefaults.standard.removeObject(forKey: DefaultKey_ImageIndex)
        UserDefaults.standard.removeObject(forKey: DefaultKey_ImageId)
        UserDefaults.standard.removeObject(forKey: DefaultKey_LastLabelingImageId)

    }
}

