//
//  SlideReferImagesVC_Gesture.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 29/05/2019.
//  Copyright © 2019 uBiz Information Technology. All rights reserved.
//

import UIKit

extension SlideReferImagesVC {

    func initGesture() {

        //setupPanGestureRecognizer()
        setupTapGestureRecognizer(numberOfTouches: 1, numberOfTaps: 1)
        setupTapGestureRecognizer(numberOfTouches: 1, numberOfTaps: 2)
        setupTapGestureRecognizer(numberOfTouches: 2, numberOfTaps: 1)
        setupTapGestureRecognizer(numberOfTouches: 3, numberOfTaps: 3)
        setupLongPressGestureRecognizer()
        setupSwipeGestureRecognizer()
    }
    
    //--------------------------------------------------------------------------------
    // Tap Gesture Set
    //--------------------------------------------------------------------------------
    func setupTapGestureRecognizer(numberOfTouches:Int, numberOfTaps:Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tapGesture.numberOfTouchesRequired = numberOfTouches
        tapGesture.numberOfTapsRequired = numberOfTaps
        collectionView.addGestureRecognizer(tapGesture)
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
            // 이미지 Zooming 초기화:Reload
            if (gesture.numberOfTapsRequired == 1) {
                collectionView.reloadData()
            }
        }
        else if (gesture.numberOfTouchesRequired == 2) {
            if (gesture.numberOfTapsRequired == 1) {
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
        
        switch gesture.state {
        case .ended, .cancelled, .failed:
            break
        default:
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
        //collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func imageLongPressed(_ gesture: UILongPressGestureRecognizer) {
        
        let currentPoint = gesture.location(in: collectionView)
        
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
        collectionView.addGestureRecognizer(panGesture)
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
        collectionView.addGestureRecognizer(pinchGesture)
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
        self.collectionView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeRight.direction = .right
        self.collectionView.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeUp.direction = .up
        self.collectionView.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeDown.direction = .down
        self.collectionView.addGestureRecognizer(swipeDown)
    }
    
    @objc func imageSwiped(_ gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Swipe Down")
        }
    }
}
