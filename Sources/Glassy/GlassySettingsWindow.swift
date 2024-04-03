//
//  GlassySettingsWindow.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

// Titlebar height: 50px


import SwiftUI

public class GlassySettingsWindow {
    var windowController: NSWindowController?
    var tabs: [SettingsTabGroup]

    public init(_ tabs: [SettingsTabGroup]) {
        self.tabs = tabs
    }

    public func show() {
        let view = NSHostingView(rootView: ContentView(self.tabs))
        print(view.bounds)

        let window = NSWindow(
            contentRect: view.bounds,
            styleMask: [
                .closable,
                .titled,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )

        window.contentView = view
        window.contentView?.wantsLayer =  true

        window.toolbarStyle = .unified
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        window.toolbar = customToolbar

        window.setBackgroundBlur(radius: 20)

        window.center()
        window.orderFrontRegardless()

        self.windowController = .init(window: window)
    }
}
