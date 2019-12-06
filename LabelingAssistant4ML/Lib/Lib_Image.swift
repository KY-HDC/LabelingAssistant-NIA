//
//  Lib_Image.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 14/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

extension UIImageView {
    // ------------------------------------------------------------------------------------
    // 이미지 뷰를 동그랗게
    // ------------------------------------------------------------------------------------
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    // ------------------------------------------------------------------------------------
    // 이미지 뷰에 설정된 이미지의 Rect
    // ------------------------------------------------------------------------------------
    func imageRect() -> CGRect {
        let imageViewSize = self.frame.size
        let imgSize = self.image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGRect.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0,
                               width: CGFloat(imageSize.width * aspect),
                               height: CGFloat(imageSize.height * aspect))
        // Center image
        imageRect.origin.x = CGFloat((imageViewSize.width - imageRect.size.width) / 2)
        imageRect.origin.y = CGFloat((imageViewSize.height - imageRect.size.height) / 2)
        
        // Add imageView offset
        imageRect.origin.x += self.frame.origin.x
        imageRect.origin.y += self.frame.origin.y
        
        return imageRect
    }
    
    // ------------------------------------------------------------------------------------
    // 이미지 뷰에 설정된 이미지의 원점
    // ------------------------------------------------------------------------------------
    func imageOrigin() -> CGPoint {
        let imageViewSize = self.frame.size
        let imgSize = self.image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGPoint.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0,
                               width: CGFloat(imageSize.width * aspect),
                               height: CGFloat(imageSize.height * aspect))
        // Center image
        imageRect.origin.x = CGFloat((imageViewSize.width - imageRect.size.width) / 2)
        imageRect.origin.y = CGFloat((imageViewSize.height - imageRect.size.height) / 2)
        
        // Add imageView offset
        imageRect.origin.x += self.frame.origin.x
        imageRect.origin.y += self.frame.origin.y
        
        imageRect.origin.x = imageRect.origin.x.rounded()
        imageRect.origin.y = imageRect.origin.y.rounded()
        
        return imageRect.origin
    }
    
    // ------------------------------------------------------------------------------------
    // 이미지 뷰에 설정된 이미지의 사이즈
    // ------------------------------------------------------------------------------------
    func imageSize() -> CGSize {
        let imageViewSize = self.frame.size
        let imgSize = self.image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGSize.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        let imageRectSize = CGSize(width: CGFloat(imageSize.width * aspect),
                                   height: CGFloat(imageSize.height * aspect))
        return imageRectSize
    }
}


extension CGRect {
    // ------------------------------------------------------------------------------------
    // 실제 이미지 사이즈에 해당하는 마크 위치 및 크기 계산
    // shape : UIImageView상에서의 위치 및 크기
    // imageOrigin : UIImageView 내부에 설정되어 보여지는 이미지의 상대 원점좌표
    // ratio : 실제이미지 대비 화면상의 이미지 비율
    // ------------------------------------------------------------------------------------
    func transToRealShape(_ imageOrigin:CGPoint, _ ratio:Float) -> CGRect {
        // 계산
        var x = (self.origin.x - imageOrigin.x) / CGFloat(ratio)
        var y = (self.origin.y - imageOrigin.y) / CGFloat(ratio)
        var width = self.width / CGFloat(ratio)
        var height = self.height / CGFloat(ratio)
        
        // 0.5 단위 반올림
        x = round((x * 2)) / 2
        y = round((y * 2)) / 2
        width = round((width * 2)) / 2
        height = round((height * 2)) / 2
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // ------------------------------------------------------------------------------------
    // 화면 상의 이미지 사이즈에 해당하는 마크 위치 및 크기 계산
    // shape : 실제 이미지 상의 마크 위치 및 크기
    // imageOrigin : UIImageView 내부에 설정되어 보여지는 이미지의 상대 원점좌표
    // ratio : 실제이미지 대비 화면상의 이미지 비율
    // ------------------------------------------------------------------------------------
    func transToViewShape(_ imageOrigin:CGPoint, _ ratio:Float) -> CGRect {
        let x = self.origin.x * CGFloat(ratio) + imageOrigin.x
        let y = self.origin.y * CGFloat(ratio) + imageOrigin.y
        let width = self.width * CGFloat(ratio)
        let height = self.height * CGFloat(ratio)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension CAShapeLayer {
    // ------------------------------------------------------------------------------------
    // ShapeLayer를 복사
    // ------------------------------------------------------------------------------------
    func copyLayer<T: CAShapeLayer>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
    // ------------------------------------------------------------------------------------
    // ShapeLayer이동시 애니메이션 안되도록
    // ------------------------------------------------------------------------------------
    class func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void){
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        actionsWithoutAnimation()
        CATransaction.commit()
    }
}

extension CALayer {
    // ------------------------------------------------------------------------------------
    // Layer의 sublayer 갯수
    // ------------------------------------------------------------------------------------
    func sublayersCount() -> Int {
        if let sublayers = self.sublayers {
            return sublayers.count
        }
        else {
            return 0
        }
    }
}
