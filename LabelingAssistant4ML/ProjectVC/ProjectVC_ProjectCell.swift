//
//  ProjectVC_ProjectCell.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 15/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

struct ProjectSection : Comparable {
    
    var projectCode : String
    var headlines : [ProjectInfo]
    
    static func < (lhs: ProjectSection, rhs: ProjectSection) -> Bool {
        return lhs.projectCode < rhs.projectCode
    }
    
    static func == (lhs: ProjectSection, rhs: ProjectSection) -> Bool {
        return lhs.projectCode == rhs.projectCode
    }
    
    static func group(headlines : [ProjectInfo]) -> [ProjectSection] {
        let groups = Dictionary(grouping: headlines) { (headline) -> String in
            return headline.code! + " - " + headline.name!
        }
        return groups.map(ProjectSection.init(projectCode:headlines:)).sorted()
    }
}


class ProjectCell: UITableViewCell {
    @IBOutlet var projectBeginEndButton: UIButton!
    @IBOutlet var order: UILabel!
    @IBOutlet var beginDate: UILabel!
    @IBOutlet var endDate: UILabel!
    @IBOutlet var progressRatio: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var orderTitle: UILabel!
    @IBOutlet var beginDateTitle: UILabel!
    @IBOutlet var endDateTitle: UILabel!
    @IBOutlet var progressTitle: UILabel!
}
