//
//  LuminarePopupPanel.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

public class LuminarePopupPanel: NSPanel, ObservableObject {
    private let closesOnDefocus: Bool
    private let initializedDate = Date.now

    public init(
        closesOnDefocus: Bool = false
    ) {
        self.closesOnDefocus = closesOnDefocus

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

    func setSize(_ size: CGSize) {
        let newSize = CGSize(
            width: size.width,
            height: size.height
        )
        let newOrigin = NSPoint(
            x: frame.origin.x,
            y: frame.origin.y - (size.height - frame.height)
        )

        if Date.now.timeIntervalSince(initializedDate) < 1.0 || (newSize.width >= frame.width && newSize.height >= frame.height) {
            setFrame(.init(origin: newOrigin, size: newSize), display: false)
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            animator().setFrame(.init(origin: newOrigin, size: newSize), display: false)
        }
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

    override public func resignKey() {
        if closesOnDefocus {
            close()
        }
    }
}
