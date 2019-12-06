//
//  SlideReferImageVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 27/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class SlideReferImageVC: UIViewController, UIScrollViewDelegate {

    var projectCode:String = ""
    var imageId:String = ""
    var referImageList:[String] = []
    var currentImageIndex = -1

    @IBOutlet var ScrollImage: UIScrollView!
    @IBOutlet var imageView: UIImageView!

    var lastScale:CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "참조 이미지"
        
        print("SlideReferImageVC projectCode = \(projectCode)")
        print("SlideReferImageVC imageId = \(imageId)")
        
        initImageViewProperty()
        initGesture()
        
        if (getReferImageList()) {
            if (referImageList.count == 0) {
                showMessage("참조할 이미지가 없습니다.")
                imageView.image = #imageLiteral(resourceName: "ImageNotRegistered")  // 디폴트 이미지 세팅
            }
            else {
                currentImageIndex = 0
                showImageFromURL(referImageList[0])
            }
        }
        else {
            showMessage(LastURLErrorMessage)
            imageView.image = #imageLiteral(resourceName: "ImageNotRegistered")  // 디폴트 이미지 세팅
        }

    }
    
    // --------------------------------------------------------------------------
    // 메인 이미지뷰 속성 설정 및 초기 이미지 설정
    // --------------------------------------------------------------------------
    func initImageViewProperty() {
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.darkGray
        
        // 초기 이미지 설정
        imageView.image = #imageLiteral(resourceName: "건양대학교병원 야경")
        imageView.contentMode = .scaleToFill
    }
    
    func showMessage(_ msg:String) {
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1
        let alert: UIAlertController = UIAlertController(title: "메세지 확인", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "확인", style: .default, handler: {(alertAction) in
            topWindow?.isHidden = true
            topWindow = nil
        }))
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showImageFromURL(_ file_name:String) {

        // ------------------------------------------------
        // 스피너 시작
        // ------------------------------------------------
        let child = SpinnerViewController()
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        initImageZoomScale()
        
        let encoded = file_name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let url = URL(string: "\(ILA4ML_URL_GETIMAGE)?file_name=\(encoded!)")
        if let data = try? Data(contentsOf: url!) {
            imageView.image = UIImage(data: data)
        }
        else {
            imageView.image = #imageLiteral(resourceName: "ImageNotRegistered")  // 디폴트 이미지 세팅
        }
        imageView.contentMode = .scaleAspectFit
        
        // ------------------------------------------------
        // 스피너 종료
        // ------------------------------------------------
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

    }
    
    func unloadMe() {
        navigationController?.popViewController(animated: true)
        
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
}
