//
//  MainVC_Gesture.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 06/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

extension LabelingVC {

    func initGesture() {
        setScrollViewPropertyForImage()                                 // 이미지 확대,축소,스크롤 처리
        setupPanGestureRecognizer()                                     // 마크 이동
        setupTapGestureRecognizer(numberOfTouches: 1, numberOfTaps: 1)  // 마크 그리기, 마크 편집 모드 해제
        setupTapGestureRecognizer(numberOfTouches: 1, numberOfTaps: 2)  // 참조 이미지 뷰어 띄우기
        setupTapGestureRecognizer(numberOfTouches: 2, numberOfTaps: 1)  // 이미지 zooming 초기화
        setupTapGestureRecognizer(numberOfTouches: 3, numberOfTaps: 3)  // 마크 그리기 활성화/비활성화
        setupLongPressGestureRecognizer()                               // 마크 편집 모드 진입
        setupScreenEdgePanGestureRecognizer()                           // 메뉴 버튼과 동일
//        setupHiddenViewTapGestureRecognizer(view: hiddenView)           // 히든뷰 탭 제스처
    }
    
    //--------------------------------------------------------------------------------
    // Tap Gesture Set
    //--------------------------------------------------------------------------------
    func setupTapGestureRecognizer(numberOfTouches:Int, numberOfTaps:Int) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tapGesture.numberOfTouchesRequired = numberOfTouches
        tapGesture.numberOfTapsRequired = numberOfTaps
        EditingImage.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        
        print("touch count:", gesture.numberOfTouchesRequired, "tap count:", gesture.numberOfTapsRequired)
        
        if (gesture.numberOfTouchesRequired == 1) {
            // 마크 그리기, 그리기 모드이면 모드 해제
            if (gesture.numberOfTapsRequired == 1) {
            }
            if (gesture.numberOfTapsRequired == 2) {
                print("참조 이미지 뷰어 보이기")
                showReferImageScreen()
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
            // 마크 활성/비활성화
            if (gesture.numberOfTapsRequired == 3) {
                markEnabled = !markEnabled
                if (markEnabled) {
                    loadUndoRedoButtonEnabledStatus()
                }
                else {
                    saveUndoRedoButtonEnabledStatus()
                }
                return
            }
        }
        else {
            return
        }
        
        if (!markEnabled) { return }
        
        let currentPoint = gesture.location(in: EditingImage)
        switch gesture.state {
        case .ended, .cancelled, .failed:
            print("imageTapped Ended: ", gesture.state.rawValue)
            break
        default:
            print("imageTapped etc. : ", gesture.state.rawValue)
            break
        }
        
        print("isEditMode:", isEditMode)
        
        if (isEditMode) {
            var positionMark = MarkShape()
            if (isMarkPosition(currentPoint, &positionMark)) {
                if (positionMark.layer != editModeMarkShape.layer) {
                    enterEditMode(markShape: positionMark)
                }
            }
            else {
                exitEditMode(exitType: EditModeExitType.Manual)
            }
        }
        else {
            drawEllipse(x:currentPoint.x, y:currentPoint.y)
        }
    }
    
    func isMarkPosition(_ currentPoint: CGPoint, _ selectedMark: inout MarkShape) -> Bool {
        var success = false
        
        for markShape in arrayMarkShapeLayer {
            if let layer = markShape.layer {
                if layer.frame.contains(currentPoint) {
                    selectedMark = markShape
                    success = true
                    break
                }
            }
        }
        return success
    }
    
//    func isMarkPosition(_ currentPoint: CGPoint, _ selectedLayer: inout CAShapeLayer) -> Bool {
//        var success = false
//        guard let subLayers = EditingImage.layer.sublayers else { return success }
//        for sublayer in subLayers {
//            if let layer = sublayer as? CAShapeLayer {
//                if layer.frame.contains(currentPoint) {
//                    selectedLayer = layer
//                    success = true
//                    break
//                }
//            }
//        }
//        return success
//    }
//
    //--------------------------------------------------------------------------------
    // LongPress Gesture Set
    //--------------------------------------------------------------------------------
    func setupLongPressGestureRecognizer() {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(imageLongPressed(_:)))
        longPressGesture.minimumPressDuration = 0.3
        longPressGesture.allowableMovement = 15 // 15 points
        longPressGesture.delaysTouchesBegan = true
        EditingImage.addGestureRecognizer(longPressGesture)
    }
    
    @objc func imageLongPressed(_ gesture: UILongPressGestureRecognizer) {
        
        if (!markEnabled) { return }
        
        let currentPoint = gesture.location(in: EditingImage)
        switch gesture.state {
        case .began:
            // 길게 눌렀을 경우에는 마크 편집 모드로 전환
            print("imageLongPressed Began: ", gesture.state.rawValue)
            
            // 이전에 편집모드인 mark가 있으면 control point 삭제
            if (isEditMode) {
                editModeMarkShape.layer!.sublayers?.removeAll()
                controlPoints.removeAll()
            }

            for markShape in arrayMarkShapeLayer {
                if markShape.layer!.frame.contains(currentPoint) {
                    enterEditMode(markShape: markShape)
                    break
                }
            }
            
//            guard let subLayers = EditingImage.layer.sublayers else { return }
//            for sublayer in subLayers {
//                if let layer = sublayer as? CAShapeLayer {
//                    if layer.frame.contains(currentPoint) {
//                        enterEditMode(shapeLayer: layer)
//                        break
//                    }
//                }
//            }
//
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
        EditingImage.addGestureRecognizer(panGesture)
    }
    
    @objc func imagePanned(_ gesture: UIPanGestureRecognizer) {
        
        if (!markEnabled) { return }

        struct Temp { static var numberOfTouchesWhenBegan = 0 }
        
        if (gesture.state == .began) {
            Temp.numberOfTouchesWhenBegan = gesture.numberOfTouches
        }
        switch Temp.numberOfTouchesWhenBegan {
        case 1:
            // 싱글터치의 경우에는 마크가 선택되었는지 체크하고 선택된 마크를 이동시킴
            adjustMark(gesture: gesture)
            break
        case 2:
            // 더블터치의 경우에는 확대된 이미지 스크롤로 사용함. 여기서는 사용 안함.
            // ScrollImage에서 사용. func viewForZooming 참조
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
        EditingImage.addGestureRecognizer(pinchGesture)
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
        self.EditingImage.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeRight.direction = .right
        self.EditingImage.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeUp.direction = .up
        self.EditingImage.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(_:)))
        swipeDown.direction = .down
        self.EditingImage.addGestureRecognizer(swipeDown)
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

    //--------------------------------------------------------------------------------
    // ScreenEdgePan Set
    //--------------------------------------------------------------------------------
    func setupScreenEdgePanGestureRecognizer() {
        let leftEdge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgeGesture(_:)))
        leftEdge.edges = UIRectEdge.left
        self.view.gestureRecognizers = [leftEdge]
    }
    
    @objc func edgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) -> Void {
        
        if gesture.edges == UIRectEdge.left {
            if (gesture.state == .recognized) {
                didTapMenu(menuButton)
            }
        }
    }

    //--------------------------------------------------------------------------------
    // 메뉴 목록 보일 때 화면에 꽉차게 임시뷰를 보이게 하고 임시뷰에 탭 제스처 추가
    //--------------------------------------------------------------------------------
//    func setupHiddenViewTapGestureRecognizer(view:UIView) {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hiddenViewTapped(_:)))
//        view.addGestureRecognizer(tapGesture)
//    }
    
//    // 임시 뷰를 탭했을때 메뉴 목록 없어지게 하고 임시뷰를 히든 처리
//    @objc func hiddenViewTapped(_ gesture: UITapGestureRecognizer) {
//        onMoreTapped()
//    }
    
}
