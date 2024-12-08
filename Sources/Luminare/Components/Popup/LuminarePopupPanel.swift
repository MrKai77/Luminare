//
//  LuminarePopupPanel.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

public class LuminarePopupPanel: NSPanel, ObservableObject {
    @Published public var onDismiss: (() -> ())?

    public init() {
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        collectionBehavior.insert(.fullScreenAuxiliary)
        level = .floating
        backgroundColor = .clear
        contentView?.wantsLayer = true
        ignoresMouseEvents = false
        isOpaque = false
        hasShadow = true
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        animationBehavior = .utilityWindow
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
