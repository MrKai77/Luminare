//
//  LuminareModalWindow.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public class LuminareModalWindow<Content> where Content: View {
    var windowController: NSWindowController?
    var content: Content
    var tint: Color

    public init(tint: Color = .accentColor, _ content: Content) {
        self.tint = tint
        self.content = content
    }

    public func show() {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }

        let view = NSHostingViewSuppressingSafeArea(
            rootView: LuminareModalView(self.content, self)
                .environment(\.tintColor, self.tint)
        )

        let window = LuminareModalNSWindow(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.backgroundColor = .clear
        window.contentView = view
        window.contentView?.wantsLayer = true

        window.ignoresMouseEvents = false
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.hasShadow = true

        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        window.center()
        window.orderFrontRegardless()

        self.windowController = .init(window: window)
    }

    func updateShadow(for duration: Double) {
        guard let window = windowController?.window else { return }

        let frameRate: Double = 60
        let interval = 1 / frameRate

        for i in 0...Int(duration * Double(frameRate)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                window.invalidateShadow()
            }
        }
    }
}
