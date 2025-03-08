//
//  LuminareDelegate.swift
//  Luminare
//
//  Created by KrLite on 2024/12/19.
//

import SwiftUI

// Should always be a struct instead of a class
public protocol LuminareDelegate: View {
    var luminare: LuminareWindow? { get set }
    var isVisible: Bool { get }

    mutating func show()
    mutating func close()
    mutating func toggle()
}

public extension LuminareDelegate {
    var isVisible: Bool {
        if let luminare {
            luminare.isVisible
        } else {
            false
        }
    }
}

public extension LuminareDelegate {
    mutating func show() {
        if luminare == nil {
            let body = body
            luminare = LuminareWindow(
                content: { body }
            )
            luminare?.center()
        }

        luminare?.show()
    }

    mutating func close() {
        luminare?.close()
        luminare = nil
    }

    mutating func toggle() {
        if isVisible {
            close()
        } else {
            show()
        }
    }
}
