//
//  LuminareCoordinator.swift
//  Luminare
//
//  Created by KrLite on 2024/12/19.
//

import SwiftUI

public protocol LuminareCoordinator: AnyObject {
    associatedtype Content: View
    var body: Content { get }

    var luminare: LuminareWindow? { get set }
    var isVisible: Bool { get }

    func showWindow()
    func closeWindow()
}

public extension LuminareCoordinator {
    var isVisible: Bool {
        luminare?.isVisible ?? false
    }

    func showWindow() {
        if luminare == nil {
            luminare = LuminareWindow {
                self.body
            }
        }

        luminare?.layoutIfNeeded()
        luminare?.center()
        luminare?.orderFrontRegardless()
    }

    func closeWindow() {
        luminare?.close()
        luminare = nil
    }
}
