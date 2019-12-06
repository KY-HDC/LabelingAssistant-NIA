//
//  SlideReferImageVC_Gesture.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 27/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

extension SlideReferImageVC {
    func initGesture() {
        setScrollViewPropertyForImage()                                 // 이미지 확대,축소,스크롤 처리
        //setupPanGestureRecognizer()                                     // 마크 이동
        setupTapGestureRecognizer(numberOfTouches: 1, numberOfTaps: 1)  // 마크 그리기, 마크 편집 모드 해제
        setupTapGestureRecognizer(numberOfTouches: 1, numberOfTaps: 2)  // dismiss
        setupTapGestureRecognizer(numberOfTouches: 2, numberOfTaps: 1)  // 이미지 zooming 초기화
        setupTapGestureRecognizer(numberOfTouches: 3, numberOfTaps: 3)  // 마크 그리기 활성화/비활성화
        setupLongPressGestureRecognizer()                               // 마크 편집 모드 진입
        setupSwipeGestureRecognizer()
    }
    
    //--------------------------------------------------------------------------------
    // Tap Gesture Set
    //--------------------------------------------------------------------------------
    func setupTapGestureRecognizer(numberOfTouches:Int, numberOfTaps:Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tapGesture.numberOfTouchesRequired = numberOfTouches
        tapGesture.numberOfTapsRequired = numberOfTaps
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        
        print("touch count:", gesture.numberOfTouchesRequired, "tap count:", gesture.numberOfTapsRequired)
        
        if (gesture.numberOfTouchesRequired == 1) {
            if (gesture.numberOfTapsRequired == 1) {
            }
            else if (gesture.numberOfTapsRequired == 2) {
                unloadMe()
            }
        }
        else if (gesture.numberOfTouchesRequired == 2) {
            // 이미지 Zooming 초기화
            if (gesture.numberOfTapsRequired == 1) {
                initImageZoomScale()
                return
            }
        }
        else if (gesture.numberOfTouchesRequired == 3) {
            if (gesture.numberOfTapsRequired == 3) {
                return
            }
        }
        else {
            return
        }
        
        let currentPoint = gesture.location(in: imageView)
        
        switch gesture.state {
        case .ended, .cancelled, .failed:
            print("imageTapped Ended: ", gesture.state.rawValue)
            break
        default:
            print("imageTapped etc. : ", gesture.state.rawValue)
            break
        }
        
    }
    
    //--------------------------------------------------------------------------------
    // LongPress Gesture Set
    //--------------------------------------------------------------------------------
    func setupLongPressGestureRecognizer() {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(imageLongPressed(_:)))
        longPressGesture.minimumPressDuration = 0.3
        longPressGesture.allowableMovement = 15 // 15 points
        longPressGesture.delaysTouchesBegan = true
        imageView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func imageLongPressed(_ gesture: UILongPressGestureRecognizer) {
        
        let currentPoint = gesture.location(in: imageView)
        
        switch gesture.state {
        case .began:
            print("imageLongPressed Began: ", gesture.state.rawValue)
            
            break
        case .ended, .cancelled, .failed:
            print("imageLongPressed Ended: ", gesture.state.rawValue)
            break
        default:
            print("imageLongPressed etc. : ", gesture.state.rawValue)
            break
        }
    }
    
    //--------------------------------------------------------------------------------
    // Pan(Drag) Gesture Set
    //--------------------------------------------------------------------------------
    func setupPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanned(_:)))
        imageView.addGestureRecognizer(panGesture)
    }
    
    @objc func imagePanned(_ gesture: UIPanGestureRecognizer) {
        
        struct Temp { static var numberOfTouchesWhenBegan = 0 }
        
        if (gesture.state == .began) {
            Temp.numberOfTouchesWhenBegan = gesture.numberOfTouches
        }

        print("imagePanned = \(Temp.numberOfTouchesWhenBegan)")

        switch Temp.numberOfTouchesWhenBegan {
        case 1:
            break
        case 2:
            // 더블터치의 경우에는 확대된 이미지 스크롤로 사용함. 여기서는 사용 안함.
            break
        case 3:
            // 트리플터치 (테스트)
            slideImage(gesture: gesture)
            break
        default:
            break
        }
        
    }
    
    // 새로운 다음 이미지, 이전 이미지 가져오기
    func slideImage(gesture: UIPanGestureRecognizer) {
        print("gesture type : slideImage")
    }
    
    //--------------------------------------------------------------------------------
    // Pinch Gesture Set
    //--------------------------------------------------------------------------------
    func setupPinchGestureRecognizer() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePinched(_:)))
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func imagePinched(_ gesture:UIPinchGestureRecognizer) {
        zoomImage(gesture: gesture)
    }
    
    func zoomImage(gesture: UIPinchGestureRecognizer) {
        if(gesture.state == .began) {
            lastScale = gesture.scale
        }
        
        if (gesture.state == .began || gesture.state == .changed) {
            let currentScale = gesture.view!.layer.value(forKeyPath:"transform.scale")! as! CGFloat
            let kMaxScale:CGFloat = 6.0
            let kMinScale:CGFloat = 1.0
            var newScale = 1 -  (lastScale - gesture.scale)
            newScale = min(newScale, kMaxScale / currentScale)
            newScale = max(newScale, kMinScale / currentScale)
            let transform = (gesture.view?.transform)!.scaledBy(x: newScale, y: newScale);
            gesture.view?.transform = transform
            lastScale = gesture.scale
        }
    }
    
    //--------------------------------------------------------------------------------
    // Swipe Gesture Set
    //--------------------------------------------------------------------------------
    func setupSwipeGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeLeft.direction = .left
        self.imageView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeRight.direction = .right
        self.imageView.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeUp.direction = .up
        self.imageView.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeDown.direction = .down
        self.imageView.addGestureRecognizer(swipeDown)
    }
    
    @objc func imageSwiped(_ gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            if (currentImageIndex - 1 < 0) {
                self.view.showToast(toastMessage: "첫번째 이미지입니다.", duration: 0.5)
                return
            }
            currentImageIndex = currentImageIndex - 1
            showImageFromURL(referImageList[currentImageIndex])
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            if (currentImageIndex + 1 >= referImageList.count) {
                self.view.showToast(toastMessage: "마지막 이미지입니다.", duration: 0.5)
                return
            }
            currentImageIndex = currentImageIndex + 1
            showImageFromURL(referImageList[currentImageIndex])
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Swipe Down")
        }
    }
    
}
