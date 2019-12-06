//
//  SlideReferImagesData.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 29/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

class SlideReferImagesData: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet var scrollImage: UIScrollView!
    @IBOutlet var img: UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    func setScrollViewPropertyForImage() {
        scrollImage.delegate = self
        scrollImage.backgroundColor = UIColor.lightGray
        scrollImage.contentSize = img.bounds.size
        
        print("scrollImage.contentSize : ", scrollImage.contentSize)
        
        scrollImage.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        scrollImage.alwaysBounceVertical = false
        scrollImage.alwaysBounceHorizontal = false
        scrollImage.showsVerticalScrollIndicator = true
        scrollImage.flashScrollIndicators()
        
        // 최소 터치수를 최소2개, 최대2개로 설정
        // 싱글터치는 이미지 자체 Pan 이벤트로 사용함.(mark용도로)
        scrollImage.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollImage.panGestureRecognizer.maximumNumberOfTouches = 2
        setImageZoomScaleInScrollView()
    }
    
    func setImageZoomScaleInScrollView() {
        
//        let imageViewSize = img.bounds.size
//        let scrollViewSize = scrollImage.bounds.size
//
//        print("imageViewSize, scrollViewSize:", imageViewSize,  ",", scrollViewSize)
//
//        let widthScale = scrollViewSize.width / imageViewSize.width
//        let heightScale = scrollViewSize.height / imageViewSize.height
//
//        scrollImage.minimumZoomScale = min(widthScale, heightScale)
//        scrollImage.maximumZoomScale = scrollImage.minimumZoomScale * 6.0

        scrollImage.minimumZoomScale = 1.0
        scrollImage.maximumZoomScale = scrollImage.minimumZoomScale * 6.0
        initImageZoomScale()
        
    }
    
    func initImageZoomScale() {
        scrollImage.zoomScale = 1
    }

}
