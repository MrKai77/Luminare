//
//  UndoModel.swift
//  Luminare
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

class UndoModel<V>: ObservableObject {
    @Published var value: V
    
    init(value: V) {
        self.value = value
    }
    
    func registerUndo(_ newValue: V, in undoManager: UndoManager?) {
        let oldValue = value
        undoManager?.registerUndo(withTarget: self) { [weak undoManager] target in
            target.value = oldValue
            target.registerUndo(oldValue, in: undoManager)
        }
        value = newValue
    }
}
