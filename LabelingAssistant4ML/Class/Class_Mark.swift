//
//  Class_Mark.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 14/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

// ------------------------------------------------------------------------------
// enum
// ------------------------------------------------------------------------------
enum MarkType:Int {
    case Ellipse = 0    // 타원
    case Polygon = 1    // 다각형
}

enum UndoRedoAction {
    case Add            // 마크가 추가됨
    case ChangeBegan    // 마크 이동 시작
    case ChangeEnded    // 마크 이동 종료
    case Remove         // 마크가 삭제됨
}

// ------------------------------------------------------------------------------
// 객체 복사 함수 생성
// ------------------------------------------------------------------------------
protocol Copyable {
    init(instance: Self)
}

extension Copyable {
    func copy() -> Self {
        return Self.init(instance: self)
    }
}

// ------------------------------------------------------------------------------
// class
// ------------------------------------------------------------------------------
class MarkShape : Copyable {
    public var layer: CAShapeLayer?
    public var type: MarkType?
    public var ellipse: CGRect?
    public var polygon: [CGPoint] = []
    public var shape: Any?
    public var id: Int?
    
    init() {
    }
    
    init(shapeLayer: CAShapeLayer) {
        layer = shapeLayer
    }
    
    required init(instance: MarkShape) {
        self.layer = instance.layer?.copyLayer()
        self.type = instance.type
        self.ellipse = instance.ellipse
        self.polygon = instance.polygon
        self.shape = instance.shape
        self.id = instance.id
    }
}

class UndoRedo {
    public var action: UndoRedoAction?
    public var markShape: MarkShape
    
    init(shape: MarkShape) {
        markShape = shape
    }
}

