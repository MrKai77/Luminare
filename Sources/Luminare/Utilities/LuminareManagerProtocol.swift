//
//  LuminareManagerProtocol.swift
//  Luminare
//
//  Created by KrLite on 2024/12/19.
//

import SwiftUI

public protocol LuminareManagerProtocol: View {
    var luminare: LuminareWindow? { get set }
    var isVisible: Bool { get }

    var blurRadius: CGFloat? { get }
    var minFrame: CGSize { get }
    var maxFrame: CGSize { get }

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

    var minFrame: CGSize {
        .init(width: 100, height: 100)
    }

    var maxFrame: CGSize {
        .init(width: CGFloat.infinity, height: CGFloat.infinity)
    }
}

public extension LuminareManagerProtocol {
    mutating func show() {
        if luminare == nil {
            let body = body
            luminare = LuminareWindow(
                blurRadius: blurRadius,
                minFrame: minFrame,
                maxFrame: maxFrame
            ) { body }
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
