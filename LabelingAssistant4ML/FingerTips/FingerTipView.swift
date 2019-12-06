//
//  FingerTipView.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 28/02/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class FingerTipView: UIImageView {

    var timestamp:TimeInterval = Date().timeIntervalSince1970
    var shouldAutomaticallyRemoveAfterTimeout:Bool = false
    var fadingOut:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
}
