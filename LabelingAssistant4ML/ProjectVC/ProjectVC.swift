//
//  ProjectVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 05/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

// user defualt key 정의
// ==============================================================================
let DefaultKey_isWorking = "isWorking"
let DefaultKey_ProjectCode = "ProjectCode"
let DefaultKey_ProjectName = "ProjectName"
let DefaultKey_LabelingOrder = "LabelingOrder"
let DefaultKey_ImageIndex = "ImageIndex"
let DefaultKey_ImageId = "ImageId"                                      // 풀 스캔 모드에서 마지막 조회된 이미지
let DefaultKey_LastLabelingImageId = "LastLabelingImageId"

// project 정보 글로벌 정의
// ==============================================================================
var isWorking = false;
var WorkingProjectCode = ""
var WorkingProjectName = ""
var WorkingLabelingOrder = 0
var WorkingImageIndex = 0
var WorkingImageId = ""                         // 풀스캔 모드 마지막 조회
var WorkingImageIdOnReviewMode = ""          // 리뷰 모드 마지막 조회
var LastLabelingImageId = ""

var ProjectList:[ProjectInfo] = [ProjectInfo]()

class ProjectVC: UIViewController {
    
    @IBOutlet var loginNameLabel: UILabel!
    @IBOutlet var tableViewProject: UITableView!
    
    var selectedProjectInfo = ProjectInfo()
    var selectedProjectSection = -1
    var selectedProjectIndex = -1

    // color set
    let workingTextColor = UIColor.black
    let workingBackColor = ColorWithHexString(hexString: "#87CEFA")
    let normalTextColor = UIColor.black
    let normalBackColor = UIColor.white
    let selectedWorkingTextColor = UIColor.blue
    let selectedWorkingBackColor = ColorWithHexString(hexString: "#DCDCDC")
    let selectedNormalTextColor = UIColor.black
    let selectedNormalBackColor = ColorWithHexString(hexString: "#DCDCDC")

    var projectSections = [ProjectSection]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        tableViewProject.rowHeight = UITableView.automaticDimension
        tableViewProject.estimatedRowHeight = UITableView.automaticDimension

        self.title = "프로젝트 목록"
        
        tableViewProject.delegate = self
        tableViewProject.dataSource = self
        tableViewProject.tableFooterView = UIView()
        
        showLoginName()

    }

    var viewDidAppearCount = 0
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        print("ProjectVC.swift viewDidAppear")
        
        viewDidAppearCount = viewDidAppearCount + 1
        if (viewDidAppearCount == 1) {
            didTapReloadButton(self)
        }
    }
    
    // ------------------------------------------------------------------------------
    // 로그인/아웃시 이벤트 받아서 처리하는 함수
    // ------------------------------------------------------------------------------
    func showLoginName() {
        if (isLogin) {
            loginNameLabel.text = LoginName
        }
        else {
            loginNameLabel.text = "not logged in"
        }
    }

    // ---------------------------------------------------------------------
    // 프로젝트 목록 갱신(서버 요청)
    // ---------------------------------------------------------------------
    @IBAction func didTapReloadButton(_ sender: Any) {
        loadProjectList()
    }
    
    
    func loadProjectList() {
        
        if (!isLogin) { return }
        
        // ------------------------------------------------
        // 진행중 메세지 표시
        // ------------------------------------------------
//        let alertProgressNoAction = UIAlertController(title: "프로젝트 목록 갱신중...\n\n\n", message: nil, preferredStyle: .alert)
//        let spinnerIndicator = UIActivityIndicatorView(style: .whiteLarge)
//        spinnerIndicator.center = CGPoint(x: 135.0, y: 85.5)
//        spinnerIndicator.color = UIColor.black
//        spinnerIndicator.startAnimating()
//        alertProgressNoAction.view.addSubview(spinnerIndicator)
//        self.present(alertProgressNoAction, animated: false, completion: nil)
        
        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = self.view.frame
        self.view.addSubview(child.view)
        child.didMove(toParent: self)

        let rp = RequestProject()
        if (rp.projectList()) {
            let ud = MyUserDefaults()
            ud.setWorkingProjectInfo(isNotiPost: false)

            // tableview section처리를 위하여...
            selectedProjectSection = -1
            selectedProjectIndex = -1
            self.projectSections = ProjectSection.group(headlines: ProjectList)
            tableViewProject.reloadData()
//            alertProgressNoAction.dismiss(animated: false, completion: nil)
        }
        else {
//            spinnerIndicator.removeFromSuperview()
//            let alertProgressNoAction = UIAlertController(title: "프로젝트 목록 로딩 메세지\n\n\n", message: nil, preferredStyle: .alert)
//            let otherAction = UIAlertAction(title: "확인", style: .default, handler: { action in
//                //self.dismiss(animated: true, completion: nil)
//                //alertProgressNoAction.dismiss(animated: true, completion: nil)
//            })
//            //alertProgressNoAction.title = "프로젝트 목록 갱신 실패\n\n\(LastURLErrorMessage)\n\n"
//            alertProgressNoAction.addAction(otherAction)
//            self.present(alertProgressNoAction, animated: false, completion: nil)

            let alertProgressNoAction = UIAlertController(title: "메시지 확인", message: "\n\n\(LastURLErrorMessage)\n\n", preferredStyle: .alert)
            let otherAction = UIAlertAction(title: "확인", style: .default, handler: { action in
                //self.dismiss(animated: true, completion: nil)
                alertProgressNoAction.dismiss(animated: true, completion: nil)
            })
            alertProgressNoAction.addAction(otherAction)
            self.present(alertProgressNoAction, animated: false, completion: nil)
        }

        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

    }
    
    // ---------------------------------------------------------------------
    // 라벨링 시작/종료 이벤트 처리
    // ---------------------------------------------------------------------
    enum enumBeginEndType:String {
        case Begin = "BEGIN", End = "END"
    }
    
    var beginEndType = enumBeginEndType.End
    
    @IBAction func projectBeginEndButtonTapped(_ sender: Any) {
        let button = sender as! UIButton
        let tag = button.tag

        if (tag == 1) {
            // 프로젝트 라벨링 시작 처리
            if (selectedProjectIndex < 0) {
                self.view.showToast(toastMessage: "선택된 프로젝트가 없습니다.", duration: 1.5)
                return
            }
            beginEndType = enumBeginEndType.Begin
            if (processBeginEnd()) {
                self.performSegue(withIdentifier: "unwindFromNewProject", sender: self)
            }
        }
        else if (tag == 0) {

            self.performSegue(withIdentifier: "unwindFromProjectList", sender: self)
            
//            if (!isWorking) {
//                self.view.showToast(toastMessage: "라벨링 중인 프로젝트가 없습니다.", duration: 1.5)
//                return
//            }
//            beginEndType = enumBeginEndType.End
//            if (processBeginEnd()) {}
        }
    }

    func processBeginEnd() -> Bool {
        var success = false
        // ------------------------------------------------
        // 진행중 메세지 표시
        // ------------------------------------------------
//        let alertProgressNoAction = UIAlertController(title: "서버에 시작/종료 정보 반영중...\n\n\n", message: nil, preferredStyle: .alert)
//        let spinnerIndicator = UIActivityIndicatorView(style: .whiteLarge)
//        spinnerIndicator.center = CGPoint(x: 135.0, y: 85.5)
//        spinnerIndicator.color = UIColor.black
//        spinnerIndicator.startAnimating()
//        alertProgressNoAction.view.addSubview(spinnerIndicator)
//        self.present(alertProgressNoAction, animated: false, completion: nil)
        
        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = self.view.frame
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
        
        if (projectBeginEnd()) {
            let rp = RequestProject()
            if (rp.projectList()) {

                // tableview section처리를 위하여...
                self.projectSections = ProjectSection.group(headlines: ProjectList)

                let ud = MyUserDefaults()
                ud.setWorkingProjectInfo(isNotiPost: true)
                
                // tableview 반영
                selectedProjectSection = -1
                selectedProjectIndex = -1
                tableViewProject.reloadData()
                
                // tableview 반영
                //alertProgressNoAction.dismiss(animated: false, completion: nil)

                switch beginEndType {
                case enumBeginEndType.Begin:
                    self.view.showToast(toastMessage: "정상적으로 시작되었습니다.", duration: 0.5)
                    break
                case enumBeginEndType.End:
                    selectedProjectSection = -1
                    selectedProjectIndex = -1
                    self.view.showToast(toastMessage: "정상적으로 종료되었습니다.", duration: 0.5)
                    break
                }
                success = true
            }
            else {
                //spinnerIndicator.removeFromSuperview()
                let alertProgressNoAction = UIAlertController(title: "메세지 확인\n\n\n", message: nil, preferredStyle: .alert)
                let otherAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                    //self.dismiss(animated: true, completion: nil)
                    alertProgressNoAction.dismiss(animated: true, completion: nil)
                })
                //alertProgressNoAction.title = "프로젝트 목록 갱신 실패\n\n\(LastURLErrorMessage)\n\n"
                alertProgressNoAction.addAction(otherAction)
                self.present(alertProgressNoAction, animated: false, completion: nil)
            }
        }
        else {
            //spinnerIndicator.removeFromSuperview()
            let alertProgressNoAction = UIAlertController(title: "메세지 확인\n\n\n", message: nil, preferredStyle: .alert)
            let otherAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                //self.dismiss(animated: true, completion: nil)
                alertProgressNoAction.dismiss(animated: true, completion: nil)
            })
            //alertProgressNoAction.title = "프로젝트 시작 실패\n\(LastURLErrorMessage)\n\n"
            alertProgressNoAction.addAction(otherAction)
            self.present(alertProgressNoAction, animated: false, completion: nil)
        }
        
        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        

        return success
    }
    
}
