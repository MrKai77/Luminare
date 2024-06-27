//
//  LuminareTrafficLightedWindow.swift
//
//
//  Created by Kai Azim on 2024-06-15.
//

import SwiftUI

// Initialize this window simply by initializing it.
public class LuminareTrafficLightedWindow<Content>: NSWindow where Content: View {
    public init(view: () -> Content) {
        super.init(
            contentRect: .zero,
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )

        let hostingView = NSHostingView(rootView: LuminareTrafficLightedWindowView(content: view())
            .environment(\.floatingPanel, self)
            .environment(\.tintColor, LuminareSettingsWindow.tint))

        backgroundColor = .clear
        contentView = hostingView
        contentView?.wantsLayer = true
        ignoresMouseEvents = false
        isOpaque = false
        hasShadow = true
        titleVisibility = .hidden

        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden

        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        toolbar = customToolbar

        center()

        DispatchQueue.main.async {
            self.makeKeyAndOrderFront(nil)
        }
    }

    func updateShadow(for duration: Double) {
        let frameRate: Double = 60
        let updatesCount = Int(duration * frameRate)
        let interval = duration / Double(updatesCount)

        for i in 0...updatesCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                self.invalidateShadow()
            }
        }
    }
}
