//
//  SlideReferImagesVC.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 29/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class SlideReferImagesVC: UIViewController {

    var projectCode:String = ""
    var imageId:String = ""
    var referImageList:[String] = []
    
    @IBOutlet var collectionView: UICollectionView!
    
    var imgArr = [UIImage(named: "Image01"),UIImage(named: "Image02"),UIImage(named: "Image03"),UIImage(named: "Image04"),UIImage(named: "Image05")]
    
    var lastScale:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "참조 이미지"
        
        initGesture()
        
    }
    
    func getImagesFromURL() {
    
        imgArr.removeAll()
        
        for file_name in referImageList {
            let encoded = file_name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let url = URL(string: "\(ILA4ML_URL_GETIMAGE)?file_name=\(encoded!)")
            if let data = try? Data(contentsOf: url!) {
                imgArr.append(UIImage(data: data))
            }
            else {
                print("image file name " + file_name + "download error")
            }
        }
        
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
    
    
    @IBAction func didTapBackButton(_ sender: UIBarButtonItem) {
        unloadMe()
    }
    
    func unloadMe() {
        performSegue(withIdentifier: "unwindFromReferImages", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}


extension SlideReferImagesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SlideReferImagesData
        cell?.img.image = imgArr[indexPath.row]
        cell?.setScrollViewPropertyForImage()
        return cell!
    }
    
}

extension SlideReferImagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
        //super.viewWillTransition(to: size, with: coordinator)
    }
}
