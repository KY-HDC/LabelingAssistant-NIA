//
//  MenuVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 20/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

enum MenuType: Int {
    case login
    case projectList
    case help
    case about
    case labeling
    case nothing
}	

class MenuVC: UITableViewController {

    var didTopMenuType: ((MenuType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }

        dismiss(animated: true) { [weak self] in
            self?.didTopMenuType?(menuType)
        }
    }
    
}
