//
//  Class_Stack.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 14/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

class Stack<T> {
    public var array = [T]()
    
    func push(_ element: T) {
        array.append(element)
    }
    func pop() -> T? {
        if (array.count < 0) {
            return nil
        }
        return array.removeLast()
    }
    func clear() {
        array.removeAll()
    }
    func remove(_ at: Int) {
        if (at >= 0) {
            array.remove(at: at)
        }
    }
    public var count: Int {
        get {
            return array.count
        }
    }
    public var items: [T] {
        get {
            return array
        }
    }
}
