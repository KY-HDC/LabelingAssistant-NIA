//
//  MainVC_Image.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 06/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

extension LabelingVC {

    //-------------------------------------------------------------------------------------
    // ScrollImage : 이미지의 확대/축소/확대된 이미지 이동 등을 위하여 사용, 이미지를 scroll view 안에서 사용
    //-------------------------------------------------------------------------------------
    func setScrollViewPropertyForImage() {
        //ScrollImage.delegate = self
        ScrollImage.backgroundColor = UIColor.darkGray
        ScrollImage.contentSize = EditingImage.bounds.size
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
        let imageViewSize = EditingImage.bounds.size
        let scrollViewSize = ScrollImage.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        ScrollImage.minimumZoomScale = min(widthScale, heightScale)
        ScrollImage.maximumZoomScale = ScrollImage.minimumZoomScale * 6.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return EditingImage
    }
    
    func initImageZoomScale() {
        ScrollImage.zoomScale = 1
    }

    func addControlPointForEllipse(layer:CAShapeLayer) {
        
        let origin = CGPoint(x:0,y:0)
        let size = layer.frame.size
        
        let color = UIColor.yellow.cgColor
        
        // outline 추가
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let shapeRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [1,1]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
        shapeLayer.frame = CGRect(x:origin.x, y:origin.y, width:size.width, height:size.height)
        outlineLayer = shapeLayer
        layer.addSublayer(shapeLayer)
        
        // 꼭지점마다 컨트롤포인트 추가
        let controlPointSize = CGSize(width: 60, height: 60)
        let controlPointLayer:CAShapeLayer = CAShapeLayer()
        controlPointLayer.fillColor = UIColor.clear.cgColor
        controlPointLayer.strokeColor = color
        controlPointLayer.lineWidth = 1
        //controlPointLayer.lineDashPattern = [1,1]
        controlPointLayer.path =
            UIBezierPath(ovalIn:CGRect(x: 0, y: 0, width: controlPointSize.width, height: controlPointSize.height)).cgPath
        controlPointLayer.frame = CGRect(origin: CGPoint(x:0,y:0), size: controlPointSize)
        
        let controlPointLayerTopLeft = controlPointLayer.copyLayer()
        let controlPointLayerTopRight = controlPointLayer.copyLayer()
        let controlPointLayerBottomLeft = controlPointLayer.copyLayer()
        let controlPointLayerBottomRight = controlPointLayer.copyLayer()
        
        controlPointLayerTopLeft.frame =
            CGRect(origin: CGPoint(x:origin.x - controlPointSize.width/2,
                                   y:origin.y - controlPointSize.height/2),
                   size: controlPointSize)
        controlPointLayerTopRight.frame =
            CGRect(origin: CGPoint(x: origin.x + size.width - controlPointSize.width/2,
                                   y: origin.y - controlPointSize.height/2),
                   size: controlPointSize)
        controlPointLayerBottomLeft.frame =
            CGRect(origin: CGPoint(x:origin.x - controlPointSize.width/2,
                                   y: origin.y + size.height - controlPointSize.height/2),
                   size: controlPointSize)
        controlPointLayerBottomRight.frame =
            CGRect(origin: CGPoint(x:origin.x + size.width - controlPointSize.width/2,
                                   y: origin.y + size.height - controlPointSize.height/2),
                   size: controlPointSize)
        
        layer.addSublayer(controlPointLayerTopLeft)
        layer.addSublayer(controlPointLayerTopRight)
        layer.addSublayer(controlPointLayerBottomLeft)
        layer.addSublayer(controlPointLayerBottomRight)
        
        controlPoints.append(controlPointLayerTopLeft)
        controlPoints.append(controlPointLayerTopRight)
        controlPoints.append(controlPointLayerBottomLeft)
        controlPoints.append(controlPointLayerBottomRight)
        
        for (index, element) in controlPoints.enumerated() {
            print("enumerated:", index, ":", element.frame)
        }
        
    }
    
    //--------------------------------------------------------------------------------
    // 이미지 위의 타원, 다각형을 이동 및 크기 조정 등
    //--------------------------------------------------------------------------------
    func adjustMark(gesture: UIPanGestureRecognizer) {
        
        let currentPoint = gesture.location(in: EditingImage)
        switch gesture.state {
        case .began:
            panPrevPoint = currentPoint
            isExistSelectedMark = false
            isExistSelectedControlPoint = false
            
            // 마크 편집 모드이면 먼저 편집중인 마크가 선택되었는지 체크한 후
            // control point가 선택되었는지 먼저 체크
            if (isEditMode) {
                if (editModeMarkShape.layer!.frame.contains(currentPoint)) {
                    isExistSelectedMark = true
                    selectedMark = editModeMarkShape
                }
                else {
                    let editMarkPoint = CGPoint(x:currentPoint.x - editModeMarkShape.layer!.frame.origin.x,
                                                y:currentPoint.y - editModeMarkShape.layer!.frame.origin.y)
                    for (index, controlPoint) in controlPoints.enumerated() {
                        if controlPoint.frame.contains(editMarkPoint) {
                            selectedControlPoint = controlPoint
                            isExistSelectedControlPoint = true
                            selectedControlPointPosition = index
                            selectedMark = editModeMarkShape
                        }
                    }
                }
            }
            
            // 편집모드 상황에서 선택된 control point가 없을 경우에 다른 mark 선택 여부를 체크함
            if (!isExistSelectedMark && !isExistSelectedControlPoint) {
                for item in arrayMarkShapeLayer {
                    if let layer = item.layer {
                        if layer.frame.contains(currentPoint) {
                            selectedMark = item
                            //selectedShapeLayer = layer
                            isExistSelectedMark = true
                            // edit mode에서 다른 layer가 선택되었으면 변경
                            if (isEditMode && selectedMark.layer != editModeMarkShape.layer) {
                                enterEditMode(markShape: selectedMark)
                            }
                        }
                    }
                }
            }
            
            if (isExistSelectedMark || isExistSelectedControlPoint) {
                markAdjustBegan(markShape: selectedMark)
            }
            break
            
        case .ended, .cancelled, .failed:
            if (isExistSelectedMark || isExistSelectedControlPoint) {
                markAdjustEnded(markShape: selectedMark)
            }
            break
            
        case .changed:
            
            touchPosition.text = String(format: "(%5.1f,%5.1f)", currentPoint.x, currentPoint.y)
            
            if (isExistSelectedControlPoint) {
                // control point의 이동으로 인한 사이즈 조정
                moveControlPoint(markShape: editModeMarkShape, controlPoint: selectedControlPoint,
                                 position: selectedControlPointPosition,
                                 x: currentPoint.x, y: currentPoint.y)
            }
            else if (isExistSelectedMark) {
                // 선택된 마크가 있을 경우에 이동
                if (isEditMode && selectedMark.layer == editModeMarkShape.layer) {
                    moveEllipse(markShape: selectedMark, x: currentPoint.x, y: currentPoint.y)
                }
                else {
                    moveEllipse(markShape: selectedMark, x: currentPoint.x, y: currentPoint.y)
                }
            }
            
            break
            
        default:
            print("imagePanned etc. : ", gesture.state.rawValue)
            break
        }
        
    }
    

    func drawEllipse(rect:CGRect) {
        
        // 타원 최초 크기 설정
        let width = rect.width
        let height = rect.height
        let pointx = rect.origin.x
        let pointy = rect.origin.y
        
        // 타원 정의
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let ovalPath = UIBezierPath(ovalIn: rect)
        
        // shapeLayer 생성
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.cgPath               // 정의된 타원을 layer에 지정
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.frame = CGRect(x:pointx, y:pointy, width:width, height:height)
        
        addMarkEllipse(shapeLayer: shapeLayer, rect: shapeLayer.frame)
        
        writeLabelMarkInfo(shapeLayer: shapeLayer)
        
    }
    
    // 화면상에서 터치한 포인트를 기준으로 디폴트 타원을 그린다.
    func drawEllipse(x: CGFloat, y: CGFloat) {
        
        // 타원 최초 크기 설정
        let width = CGFloat(160)
        let height = CGFloat(160)
        let pointx = x - width / 2
        let pointy = y - height / 2
        
        drawEllipse(rect: CGRect(x: pointx, y: pointy, width: width, height: height))
        
//        // 타원 정의
//        let rect = CGRect(x: 0, y: 0, width: width, height: height)
//        let ovalPath = UIBezierPath(ovalIn: rect)
//
//        // shapeLayer 생성
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = ovalPath.cgPath               // 정의된 타원을 layer에 지정
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = UIColor.red.cgColor
//        shapeLayer.lineWidth = 2.0
//        shapeLayer.frame = CGRect(x:pointx, y:pointy, width:width, height:height)
//
//        addMarkEllipse(shapeLayer: shapeLayer, rect: shapeLayer.frame)
//
//        writeLabelMarkInfo(shapeLayer: shapeLayer)
        
    }
    
    func writeLabelMarkInfo(shapeLayer: CAShapeLayer) {
        if let ratio = imageRealViewRatio {
            let realFrame = shapeLayer.frame.transToRealShape(EditingImage.imageOrigin(), ratio)
            selectedMarkInfo.text = String(format: "(x:%5.1f, y:%5.1f, w:%5.1f, h:%5.1f)",
                                           realFrame.origin.x, realFrame.origin.y,
                                           realFrame.width, realFrame.height)
        }
    }
    
    // ------------------------------------------------------------------------------
    // 마크 이동, 컨트롤포인트 조절
    // ------------------------------------------------------------------------------
    func moveEllipse(markShape: MarkShape, x: CGFloat, y: CGFloat) {
        
        let shapeLayer = markShape.layer!
        
        let prevOrigin = shapeLayer.frame.origin
        let gapPoint = CGPoint(x:x - panPrevPoint.x, y:y - panPrevPoint.y)
        
        panPrevPoint = CGPoint(x:x, y:y)
        
        let newOrigin = CGPoint(x:prevOrigin.x + gapPoint.x, y:prevOrigin.y + gapPoint.y)
        disableAnimation {
            shapeLayer.frame.origin = newOrigin
        }
        markShape.shape = shapeLayer.frame
        
        writeLabelMarkInfo(shapeLayer: shapeLayer)
        
    }
    
    func moveControlPoint(markShape: MarkShape, controlPoint: CAShapeLayer, position:Int, x: CGFloat, y: CGFloat) {
        
        let shapeLayer = markShape.layer!
        
        // 이동 정지 여부 체크
        var pointx = x
        var pointy = y
        let gapPoint = CGPoint(x:x - panPrevPoint.x, y:y - panPrevPoint.y)
        
        switch position {
        case 0: // TopLeft
            if (shapeLayer.frame.origin.x + gapPoint.x >= shapeLayer.frame.origin.x + shapeLayer.frame.width) {
                pointx = panPrevPoint.x
            }
            if (shapeLayer.frame.origin.y + gapPoint.y >= shapeLayer.frame.origin.y + shapeLayer.frame.height) {
                pointy = panPrevPoint.y
            }
            break
        case 1: // TopRight
            if (shapeLayer.frame.origin.x + shapeLayer.frame.width + gapPoint.x <= shapeLayer.frame.origin.x) {
                pointx = panPrevPoint.x
            }
            if (shapeLayer.frame.origin.y + gapPoint.y >= shapeLayer.frame.origin.y + shapeLayer.frame.height) {
                pointy = panPrevPoint.y
            }
            break
        case 2: // BottomLeft
            if (shapeLayer.frame.origin.x + gapPoint.x >= shapeLayer.frame.origin.x + shapeLayer.frame.width) {
                pointx = panPrevPoint.x
            }
            if (shapeLayer.frame.origin.y + shapeLayer.frame.height + gapPoint.y <= shapeLayer.frame.origin.y) {
                pointy = panPrevPoint.y
            }
            break
        case 3: // BottomRight
            if (shapeLayer.frame.origin.x + shapeLayer.frame.width + gapPoint.x <= shapeLayer.frame.origin.x) {
                pointx = panPrevPoint.x
            }
            if (shapeLayer.frame.origin.y + shapeLayer.frame.height + gapPoint.y <= shapeLayer.frame.origin.y) {
                pointy = panPrevPoint.y
            }
            break
        default:
            break
        }
        
        // control point 이동
        moveControlPoints(markShape:markShape, controlPoint: controlPoint, position: position, x: pointx, y: pointy)
        
    }
    
    func moveControlPoints(markShape:MarkShape, controlPoint: CAShapeLayer, position:Int, x: CGFloat, y: CGFloat) {
        
        let shapeLayer = markShape.layer!
        
        let gapPoint = CGPoint(x:x - panPrevPoint.x, y:y - panPrevPoint.y)
        var newOrigin:CGPoint = CGPoint()
        var index = 0
        
        switch position {
        case 0:
            // mark layer, topleft control layer
            newOrigin = CGPoint(x:shapeLayer.frame.origin.x + gapPoint.x,
                                y:shapeLayer.frame.origin.y + gapPoint.y)
            disableAnimation {
                shapeLayer.frame.origin = newOrigin
            }
            
            // topright control layer
            index = 1
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x - gapPoint.x,
                                y:controlPoints[index].frame.origin.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            
            // bottomleft control layer
            index = 2
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x,
                                y:controlPoints[index].frame.origin.y - gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            
            // bottomright control layer
            index = 3
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x - gapPoint.x,
                                y:controlPoints[index].frame.origin.y - gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            break
        case 1:
            // mark layer, topleft control layer
            newOrigin = CGPoint(x:shapeLayer.frame.origin.x,
                                y:shapeLayer.frame.origin.y + gapPoint.y)
            disableAnimation {
                shapeLayer.frame.origin = newOrigin
            }
            
            // topright control layer
            index = 1
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x + gapPoint.x,
                                y:controlPoints[index].frame.origin.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            
            // bottomleft control layer
            index = 2
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x,
                                y:controlPoints[index].frame.origin.y - gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            // bottomright control layer
            index = 3
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x + gapPoint.x,
                                y:controlPoints[index].frame.origin.y - gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            break
        case 2:
            // mark layer, topleft control layer
            newOrigin = CGPoint(x:shapeLayer.frame.origin.x + gapPoint.x,
                                y:shapeLayer.frame.origin.y)
            disableAnimation {
                shapeLayer.frame.origin = newOrigin
            }
            
            // topright control layer
            index = 1
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x - gapPoint.x,
                                y:controlPoints[index].frame.origin.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            
            // bottomleft control layer
            index = 2
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x,
                                y:controlPoints[index].frame.origin.y + gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            
            // bottomright control layer
            index = 3
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x - gapPoint.x,
                                y:controlPoints[index].frame.origin.y + gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            break
        case 3:
            // topright control layer
            index = 1
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x + gapPoint.x,
                                y:controlPoints[index].frame.origin.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            
            // bottomleft control layer
            index = 2
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x,
                                y:controlPoints[index].frame.origin.y + gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            
            // bottomright control layer
            index = 3
            newOrigin = CGPoint(x:controlPoints[index].frame.origin.x + gapPoint.x,
                                y:controlPoints[index].frame.origin.y + gapPoint.y)
            disableAnimation {
                controlPoints[index].frame.origin = newOrigin
            }
            break
        default:
            break
        }
        
        // outline과 ellipse 사이즈 조정
        let shapeWidth = controlPoints[1].frame.origin.x - controlPoints[0].frame.origin.x
        let shapeHeight = controlPoints[2].frame.origin.y - controlPoints[0].frame.origin.y
        let shapeSize = CGSize(width: shapeWidth, height: shapeHeight)
        let shapeRect = CGRect(origin: .zero, size: shapeSize)
        
        disableAnimation {
            shapeLayer.path = UIBezierPath(ovalIn:shapeRect).cgPath
            shapeLayer.frame = CGRect(origin: shapeLayer.frame.origin, size: shapeSize)
            outlineLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
            outlineLayer.frame = CGRect(origin: .zero, size: shapeSize)
        }
        
        panPrevPoint = CGPoint(x:x, y:y)
        
        markShape.shape = shapeLayer.frame

        writeLabelMarkInfo(shapeLayer: shapeLayer)

    }
    

}
