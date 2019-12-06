//
//  SlideReferImageVC_image.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 27/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

extension SlideReferImageVC {
    
    //-------------------------------------------------------------------------------------
    // ScrollImage : 이미지의 확대/축소/확대된 이미지 이동 등을 위하여 사용, 이미지를 scroll view 안에서 사용
    //-------------------------------------------------------------------------------------
    func setScrollViewPropertyForImage() {
        //ScrollImage.delegate = self
        ScrollImage.backgroundColor = UIColor.darkGray
        ScrollImage.contentSize = imageView.bounds.size
        ScrollImage.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        ScrollImage.alwaysBounceVertical = false
        ScrollImage.alwaysBounceHorizontal = false
        ScrollImage.showsVerticalScrollIndicator = true
        ScrollImage.flashScrollIndicators()
        
        // 최소 터치수를 최소2개, 최대2개로 설정
        // 싱글터치는 이미지 자체 Pan 이벤트로 사용함.(mark용도로)
        ScrollImage.panGestureRecognizer.minimumNumberOfTouches = 2
        ScrollImage.panGestureRecognizer.maximumNumberOfTouches = 2
        setImageZoomScaleInScrollView()
    }
    
    func setImageZoomScaleInScrollView() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = ScrollImage.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        ScrollImage.minimumZoomScale = min(widthScale, heightScale)
        ScrollImage.maximumZoomScale = ScrollImage.minimumZoomScale * 6.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func initImageZoomScale() {
        ScrollImage.zoomScale = 1
    }
    
}
