//
//  Lib_UIObject.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 24/10/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

public extension UIButton {
    // ------------------------------------------------------------------------------------
    // 버튼에 설정된 이미지의 아래 부분에 글씨 넣기
    // ------------------------------------------------------------------------------------
    func alignTextBelow(spacing: CGFloat = 6.0) {
        if let image = self.imageView?.image {
            let imageSize: CGSize = image.size
            self.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -imageSize.width, bottom: -(imageSize.height), right: 0.0)
            let labelString = NSString(string: self.titleLabel!.text!)
            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: self.titleLabel!.font])
            self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        }
    }
    
    // ------------------------------------------------------------------------------------
    // 버튼 모서리 둥글게
    // ------------------------------------------------------------------------------------
    func setRounded() {
        self.layer.backgroundColor = UIColor.init(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha: 1.0).cgColor
        self.layer.cornerRadius = 10;
        self.clipsToBounds = true;
    }
}

extension UILabel {
    // ------------------------------------------------------------------------------------
    // 라벨 글씨에 언더라인 표시
    // ------------------------------------------------------------------------------------
    func underlineStyle() {
        let text = self.text
        let textRange = NSRange(location: 0, length: (text?.count)!)
        let attributedText = NSMutableAttributedString(string: text!)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
        self.attributedText = attributedText    }
}


extension UIViewController {
    func dismissMe(animated: Bool, completion: (()->())?) {
        var count = 0
        if let c = self.navigationController?.viewControllers.count {
            count = c
        }
        if count > 1 {
            self.navigationController?.popViewController(animated: animated)
            if let handler = completion {
                handler()
            }
        } else {
            dismiss(animated: animated, completion: completion)
        }
    }
}

extension UIViewController {
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
}

extension UILabel {
    
    func startBlink() {
        stopBlink()
        UIView.animate(withDuration: 1.0,
                       delay:0.0,
                       options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0 },
                       completion: nil)
    }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
