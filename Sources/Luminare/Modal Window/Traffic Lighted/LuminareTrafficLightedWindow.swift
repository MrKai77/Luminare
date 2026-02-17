//
//  LuminareTrafficLightedWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-06-15.
//

import SwiftUI

public class LuminareTrafficLightedWindow<Content>: NSWindow, ObservableObject where Content: View {
    public init(@ViewBuilder view: @escaping () -> Content) {
        super.init(
            contentRect: .zero,
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )

        let hostingView = NSHostingView(rootView: LuminareTrafficLightedWindowView(content: view))

        backgroundColor = .clear
        contentView = hostingView
        contentView?.wantsLayer = true
        ignoresMouseEvents = false
        isOpaque = false
        hasShadow = true
        titleVisibility = .hidden
        alphaValue = 0

        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden

        let toolbar = NSToolbar()
        toolbar.showsBaselineSeparator = false
        if #available(macOS 15.0, *) {
            toolbar.allowsDisplayModeCustomization = false
        }
        self.toolbar = toolbar

        layoutIfNeeded()
        center()
    }

    override public func orderFrontRegardless() {
        super.orderFrontRegardless()

        DispatchQueue.main.async {
            self.center()
            self.alphaValue = 1
        }
    }

    func updateShadow(for duration: Double) {
        let frameRate: Double = 60
        let updatesCount = Int(duration * frameRate)
        let interval = duration / Double(updatesCount)

        for index in 0...updatesCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * interval) {
                self.invalidateShadow()
            }
        }
    }
}
