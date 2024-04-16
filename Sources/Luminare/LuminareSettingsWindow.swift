//
//  LuminareSettingsWindow.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

// Titlebar height: 50px

import SwiftUI

public class LuminareSettingsWindow {
    static let identifier = NSUserInterfaceItemIdentifier("LuminareSettingsWindow")

    var windowController: NSWindowController?
    var tabs: [SettingsTabGroup]
    var tint: Color

    public init(_ tabs: [SettingsTabGroup], tint: Color = .accentColor) {
        self.tabs = tabs
        self.tint = tint
    }

    public func show() {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }

        let view = NSHostingView(
            rootView: ContentView(self.tabs)
                .environment(\.tintColor, self.tint)
        )

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

        // Makes the toolbar THICK
        window.toolbarStyle = .unified
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.identifier = LuminareSettingsWindow.identifier

        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        window.toolbar = customToolbar

        // Private API
        window.setBackgroundBlur(radius: 20)

        window.center()
        window.orderFrontRegardless()

        self.windowController = .init(window: window)
    }
}
