//
//  MainVC_TV.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 24/10/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

extension LabelingVC: UITableViewDelegate, UITableViewDataSource  {

    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.rowHeight =
            CGFloat(tableView.frame.height / CGFloat(LabelList.getLabelCount(location: tableView.tag)))
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("numberOfRowsInSection count:", labelInfoList.getLabelCount(location: tableView.tag))
        return LabelList.getLabelCount(location: tableView.tag)
        //return getLabelCount(tableView.tag)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: getCellIdentifier(tableView.tag), for: indexPath)
        
        // data mapping
        //let label = labels(tableView.tag)[indexPath.row]
        let label = LabelList.getLabelText(location: tableView.tag)[indexPath.row]
        cell.textLabel!.text = label
        
        // property mapping
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2) // 세로모드
        cell.textLabel?.textAlignment = .center
        
        if (getLastSelectedIndex(tableView.tag) == indexPath.row) {
            cell.textLabel?.textColor = selectedCellTextColor
            cell.backgroundColor = selectedCellBackgroundColor
        }
        else {
            cell.textLabel?.textColor = defaultCellTextColor
            cell.backgroundColor = defaultCellBackgroundColor
        }
        
        // 리뷰 모드일 경우에는 선택된 라벨의 글씨 색상을 변경
        if (IsReviewMode) {
            if ((tableView.tag == 0 &&  indexPath.row == LeftIndexOnReviewMode) ||
                (tableView.tag == 1 &&  indexPath.row == RightIndexOnReviewMode)) {
                cell.textLabel?.textColor = UIColor.blue
            }
        }
        
        return cell
    }
    
    func labels(_ tag: Int) -> [String] {
        if (tag == 0) {
            return labelsLeft
        }
        else {
            return labelsRight
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setLastSelectedIndex(tableView.tag, indexPath.row)
        checkSaveButtonShow()
        tableView.reloadData()
    }
    
    func getCellIdentifier(_ tag: Int) -> String {
        if (tag == 0) {
            return "LabelCellLeft"
        }
        else if (tag == 1) {
            return "LabelCellRight"
        }
        else {
            return ""
        }
    }
    
    func setLastSelectedIndex(_ tag: Int,_ index: Int) {
        let selectedLabelIndex = getLastSelectedIndex(tag)
        if (tag == 0) {
            (selectedLabelIndex == index) ? (selectedLabelLeftIndex = -1) : (selectedLabelLeftIndex = index)
        }
        else if (tag == 1) {
            (selectedLabelIndex == index) ? (selectedLabelRightIndex = -1) : (selectedLabelRightIndex = index)
        }
    }

    func getLastSelectedIndex(_ tag: Int) -> Int {
        if (tag == 0) {
            return selectedLabelLeftIndex
        }
        else if (tag == 1) {
            return selectedLabelRightIndex
        }
        else {
            return -1
        }
    }
    
}
