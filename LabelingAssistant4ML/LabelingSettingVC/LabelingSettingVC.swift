//
//  LabelingSettingVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 05/06/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class LabelingSettingVC: UIViewController {

    @IBOutlet var reviewModeSwitch: UISwitch!
    @IBOutlet var tableViewLabelLeft: UITableView!
    @IBOutlet var tableViewLabelRight: UITableView!
    
    // ------------------------------------------------------------------------------
    // color
    // ------------------------------------------------------------------------------
    let defaultCellBackgroundColor = UIColor.init(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha: 1.0)
    let defaultCellTextColor = UIColor.black
    let selectedCellBackgroundColor = UIColor.orange
    let selectedCellTextColor = UIColor.white
    
    var selectedLabelLeftIndex = -1
    var selectedLabelRightIndex = -1
    var tableViewCellHeight = 10

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "라벨링 리뷰 모드 설정"

        initBarButtons()
        initValues()
        initTableViewProperty()

    }
    
    func initBarButtons() {
        let saveItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Save"), style: .plain, target: self, action: #selector(saveSetting(_:)))
        self.navigationItem.rightBarButtonItems = [saveItem]
    }
    
    @objc func saveSetting(_ sender: UIButton) {
        print("saving setting infomation")
        
        IsReviewMode = reviewModeSwitch.isOn
        
        LeftIndexOnReviewMode = selectedLabelLeftIndex
        RightIndexOnReviewMode = selectedLabelRightIndex

        // 저장 버튼이 클릭되었음을 저장하여, 메인 화면 리프레시
        IsSettingValueChanged = true
        
        performSegue(withIdentifier: "unwindFromLabelingSetting", sender: self)
    }
    
    func initValues() {
        reviewModeSwitch.isOn = IsReviewMode
        selectedLabelLeftIndex = LeftIndexOnReviewMode
        selectedLabelRightIndex = RightIndexOnReviewMode
    }
    
    // --------------------------------------------------------------------------
    // 라벨 목록을 보여주는 좌.우 테이블뷰의 속성 초기화
    // --------------------------------------------------------------------------
    func initTableViewProperty() {
        // tableView delegate, datasource 설정
        tableViewLabelLeft.delegate = self
        tableViewLabelLeft.dataSource = self
        tableViewLabelLeft.tag = 0
        // tableView 2개를 사용하기 위하여 등록해야 함
        tableViewLabelLeft.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCellLeft")
        
        tableViewLabelRight.delegate = self
        tableViewLabelRight.dataSource = self
        tableViewLabelRight.tag = 1
        // tableView 2개를 사용하기 위하여 등록해야 함
        tableViewLabelRight.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCellRight")
        //tableViewLabelLeft.rowHeight = UITableViewAutomaticDimension
    }
    
    
    @IBAction func didTapReviewModeSwitch(_ sender: UISwitch) {
        if (reviewModeSwitch.isOn) {
            IncludeLabelingDoneImage = false
        }
        else {
            IncludeLabelingDoneImage = true
        }
    }
    
}
