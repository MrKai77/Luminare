//
//  LuminareManagerProtocol.swift
//  Luminare
//
//  Created by KrLite on 2024/12/19.
//

import SwiftUI

// Should always be a struct instead of a class
public protocol LuminareManagerProtocol: View {
    var luminare: LuminareWindow? { get set }
    var isVisible: Bool { get }

    var blurRadius: CGFloat? { get }

    mutating func show()
    mutating func close()
    mutating func toggle()
}

public extension LuminareManagerProtocol {
    var isVisible: Bool {
        if let luminare {
            luminare.isVisible
        } else {
            false
        }
    }

    var blurRadius: CGFloat? {
        nil
    }
}

public extension LuminareManagerProtocol {
    mutating func show() {
        if luminare == nil {
            let body = body
            luminare = LuminareWindow(
                blurRadius: blurRadius,
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
