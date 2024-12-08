//
//  LuminarePopupPanel.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

public class LuminarePopupPanel: NSPanel, ObservableObject {
    public static let cornerRadius: CGFloat = 12

    @Published public var onDismiss: (() -> ())?

    public init() {
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        level = .floating
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        animationBehavior = .utilityWindow

        isOpaque = false
        backgroundColor = .clear
        isMovable = false

        ignoresMouseEvents = false
        becomesKeyOnlyIfNeeded = true
    }

    override public var canBecomeKey: Bool {
        true
    }

    override public var canBecomeMain: Bool {
        false
    }

    override public var acceptsFirstResponder: Bool {
        true
    }

    override public func close() {
        onDismiss?()
        super.close()
    }
}
