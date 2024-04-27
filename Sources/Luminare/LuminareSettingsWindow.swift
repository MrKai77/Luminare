//
//  LuminareSettingsWindow.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

// Titlebar height: 50px

import SwiftUI

public class LuminareSettingsWindow {
    static var identifier = NSUserInterfaceItemIdentifier("LuminareSettingsWindow")
    var windowController: NSWindowController?
    var tabs: [SettingsTabGroup]
    static var tint: Color = .accentColor

    public init(_ tabs: [SettingsTabGroup], tint: Color = .accentColor) {
        self.tabs = tabs
        LuminareSettingsWindow.tint = tint
    }

    public func show() {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            windowController.window?.center()
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = NSHostingView(
            rootView: ContentView(self.tabs)
                .environment(\.tintColor, LuminareSettingsWindow.tint)
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

        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        window.toolbar = customToolbar

        // Private API
        window.setBackgroundBlur(radius: 20)
//        self.swizzleWidgets()
        window.identifier = LuminareSettingsWindow.identifier

        window.center()
        window.orderFrontRegardless()

        self.windowController = .init(window: window)
    }

//    func swizzleWidgets() {
//        let original = Selector("updateLayer")
//        let swizzle = Selector("xxx_updateLayer")
//        if let widgetClass = NSClassFromString("NSMenu"), // NSWidgetView
//            let originalMethod = class_getInstanceMethod(widgetClass, original),
//            let swizzleMethod = class_getInstanceMethod(NSView.self, swizzle) {
//            method_exchangeImplementations(originalMethod, swizzleMethod)
//        }
//    }
}
