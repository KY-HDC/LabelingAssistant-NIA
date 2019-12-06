//
//  ProjectVC_TV.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 05/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

extension ProjectVC: UITableViewDelegate, UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.projectSections.count
    }

    // func add
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.projectSections[section]
        let projectCode = section.projectCode
        return projectCode
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == selectedProjectSection && indexPath.row == selectedProjectIndex) {
            return 120
        }
        else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.projectSections[section]
        return section.headlines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
        
        let section = self.projectSections[indexPath.section]
        let headline = section.headlines[indexPath.row]
        
        cell.order.text = String(format: "%d", headline.labeling_ord!)
        cell.beginDate.text = headline.begin_dt!
        cell.endDate.text = headline.end_dt!
        
        var rate:Float = 0
        if (headline.total_num != 0) {
            rate = Float(headline.complete_num!) / Float(headline.total_num!)
        }
        
        cell.progressRatio.text = String(format: "%4.1f%%(%4d/%4d)", rate*100, headline.complete_num!, headline.total_num!)
        cell.progress.progress = rate
        
        cell.progress.transform = CGAffineTransform(scaleX: 1, y: 5)
        cell.progress.clipsToBounds = true
        
        cell.projectBeginEndButton.layer.cornerRadius = 10
        cell.projectBeginEndButton.layer.backgroundColor = UIColor.white.cgColor
        
        if (headline.working!) {
            // tag에 버튼 종류(시작/종료) 설정
            // 버튼 액션 projectBeginEndButtonTapped에서 tag값을 사용함
            cell.projectBeginEndButton.tag = 0
            cell.projectBeginEndButton.setTitle("메인화면 복귀", for: .normal)
            cell.contentView.backgroundColor = workingBackColor
            setCellLabelColor(cell, workingTextColor)
        }
        else {
            // tag에 버튼 종류(시작/종료) 설정
            // 버튼 액션 projectBeginEndButtonTapped에서 tag값을 사용함
            cell.projectBeginEndButton.tag = 1
            cell.projectBeginEndButton.setTitle("라벨링 시작", for: .normal)
            cell.contentView.backgroundColor = normalBackColor
            setCellLabelColor(cell, normalTextColor)
        }

        return cell
    }
    
    func setCellLabelColor(_ cell:ProjectCell, _ color:UIColor) {
        cell.order.textColor = color
        cell.beginDate.textColor = color
        cell.endDate.textColor = color
        cell.progressRatio.textColor = color
        cell.orderTitle.textColor = color
        cell.beginDateTitle.textColor = color
        cell.endDateTitle.textColor = color
        cell.progressTitle.textColor = color
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProjectCell

        let section = self.projectSections[indexPath.section]
        let headline = section.headlines[indexPath.row]

        if (headline.working!) {
            cell.contentView.backgroundColor = selectedWorkingBackColor
            setCellLabelColor(cell, selectedWorkingTextColor)
        }
        else {
            cell.contentView.backgroundColor = selectedNormalBackColor
            setCellLabelColor(cell, selectedNormalTextColor)
        }
        cell.projectBeginEndButton.layer.backgroundColor = UIColor.white.cgColor

        selectedProjectSection = indexPath.section
        selectedProjectIndex = indexPath.row
        selectedProjectInfo = headline
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProjectCell

        let section = self.projectSections[indexPath.section]
        let headline = section.headlines[indexPath.row]
        
        if (headline.working!) {
            cell.contentView.backgroundColor = workingBackColor
            setCellLabelColor(cell, workingTextColor)
        }
        else {
            cell.contentView.backgroundColor = normalBackColor
            setCellLabelColor(cell, normalTextColor)
        }
        cell.projectBeginEndButton.layer.backgroundColor = UIColor.white.cgColor
    }
}
