//
//  MainVC_UndoRedo.swift
//  LabelingAssistant4ML
//
//  Created by Myeong-Joon Son on 06/11/2018.
//  Copyright © 2018 uBiz Information Technology. All rights reserved.
//

import UIKit

extension LabelingVC {

    // add undo stack
    func pushUndoStack(markShape: MarkShape, action:UndoRedoAction) {
        
        let undoShape = markShape.copy()
        
        undoShape.layer?.sublayers?.removeAll()
        
        let undo = UndoRedo(shape: undoShape)
        undo.action = action
        pushUndoStack(undo: undo)
        
    }
    
    func pushUndoStack(undo: UndoRedo) {
        undoMarkStack.push(undo)
        undoButton.isEnabled = true
        resetButton.isEnabled = true
        printUndo()
    }
    
    func popUndoStack() {
        
        guard let undo = undoMarkStack.pop() else { return }
        print("popUndoStack:", undo.markShape.id!, ", ", undo.action!)
        printUndo()
        
        if (undo.action == UndoRedoAction.Add) {
            removeMarkShape(markShape: undo.markShape, removeType:RemoveType.Undo)
        }
        else if (undo.action == UndoRedoAction.Remove) {
            addMarkShape(markShape: undo.markShape, addType: AddType.Undo)
        }
        else if (undo.action == UndoRedoAction.ChangeBegan) {
            addMarkShape(markShape: undo.markShape, addType: AddType.Undo)
        }
        else if (undo.action == UndoRedoAction.ChangeEnded) {
            removeMarkShape(markShape: undo.markShape, removeType:RemoveType.Undo)
        }
        
        if (undoMarkStack.count == 0) {
            undoButton.isEnabled = false
            resetButton.isEnabled = false
        }
        
        pushRedoStack(redo: undo)
        
        if (undo.action == UndoRedoAction.ChangeEnded) {
            popUndoStack()
        }
    }
    
    func pushRedoStack(redo: UndoRedo) {
        redoMarkStack.push(redo)
        redoButton.isEnabled = true
        printRedo()
    }
    
    func clearRedoStack() {
        redoMarkStack.clear()
        redoButton.isEnabled = false
        printRedo()
    }
    
    func clearUndoStack() {
        undoMarkStack.clear()
        undoButton.isEnabled = false
        resetButton.isEnabled = false
        printUndo()
    }
    
    func popRedoStack() {
        guard let redo = redoMarkStack.pop() else { return }
        printRedo()
        
        if (redo.action == UndoRedoAction.Add) {
            addMarkShape(markShape: redo.markShape, addType: AddType.Redo)
        }
        else if (redo.action == UndoRedoAction.Remove) {
            removeMarkShape(markShape: redo.markShape, removeType: RemoveType.Redo)
        }
        else if (redo.action == UndoRedoAction.ChangeBegan) {
            removeMarkShape(markShape: redo.markShape, removeType: RemoveType.Began)
            popRedoStack()
        }
        else if (redo.action == UndoRedoAction.ChangeEnded) {
            addMarkShape(markShape: redo.markShape, addType: AddType.Ended)
        }
        
        if (redoMarkStack.count == 0) {
            redoButton.isEnabled = false
        }
    }
    
    enum AddType {
        case Real
        case Undo
        case Redo
        case Began
        case Ended
    }
    
    enum RemoveType {
        case Real
        case Undo
        case Redo
        case Began
        case Ended
    }
    
    func printUndo() {
//        print("undoMarkStack:count=", undoMarkStack.count)
//        for (index, item) in undoMarkStack.array.enumerated() {
//            print("undoMarkStack:", index, ",", item.markShape.id!, ",", item.action!)
//        }
    }
    
    func printRedo() {
//        print("redoMarkStack:count=", redoMarkStack.count)
//        for (index, item) in redoMarkStack.array.enumerated() {
//            print("redoMarkStack:", index, ",", item.markShape.id!, ",", item.action!)
//        }
    }
    
    struct ButtonEnabledStatus {
        static var Reset = false
        static var Undo = false
        static var Redo = false
        static var Trash = false
    }

    // 마크 비활성화시 관련 버튼의 상태를 저장후 버튼 비활성화
    func saveUndoRedoButtonEnabledStatus() {
        ButtonEnabledStatus.Reset = resetButton.isEnabled
        ButtonEnabledStatus.Undo = undoButton.isEnabled
        ButtonEnabledStatus.Redo = redoButton.isEnabled
        ButtonEnabledStatus.Trash = trashButton.isEnabled
        
        if (!markEnabled) {
            resetButton.isEnabled = false
            undoButton.isEnabled = false
            redoButton.isEnabled = false
            trashButton.isEnabled = false
        }

        isMarkEnabledImage.backgroundColor = markEnabled ? UIColor.green : UIColor.yellow
        
    }
    
    // 마크 활성화시 관련 버튼의 기존 상태를 읽어 버튼 활성화 처리
    func loadUndoRedoButtonEnabledStatus() {
        resetButton.isEnabled = ButtonEnabledStatus.Reset
        undoButton.isEnabled = ButtonEnabledStatus.Undo
        redoButton.isEnabled = ButtonEnabledStatus.Redo
        trashButton.isEnabled = ButtonEnabledStatus.Trash
        
        isMarkEnabledImage.backgroundColor = UIColor.green
    }
    
}
