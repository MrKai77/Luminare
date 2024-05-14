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
    static var tint: () -> Color = { .accentColor }

    private let didTabChange: (SettingsTab) -> Void
    private var previewView: NSView?

    public init(
        _ tabs: [SettingsTabGroup],
        tint: @escaping () -> Color = { .accentColor },
        didTabChange: @escaping (SettingsTab) -> Void
    ) {
        self.tabs = tabs
        LuminareSettingsWindow.tint = tint
        self.didTabChange = didTabChange
    }

    public func show() {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            windowController.window?.center()
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = NSHostingView(
            rootView: ContentView(self.tabs, didTabChange: didTabChange)
                .environment(\.tintColor, LuminareSettingsWindow.tint)
        )

        let window = NSWindow(
            contentRect: view.bounds,
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false // If true, background blur will break
        )

        window.contentView = view
        window.contentView?.wantsLayer =  true

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

    public func setPreviewView<Content: View>(_ view: Content) {
        if let previewView = previewView {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.1
                previewView.animator().alphaValue = 0
            }, completionHandler: {
                previewView.removeFromSuperview()
            })
        }

        let windowSize = windowController?.window?.frame.size ?? .zero

        let view = NSHostingView(rootView: AnyView(view.ignoresSafeArea()))
        view.setFrameSize(NSSize(width: 520, height: 650))
        view.setFrameOrigin(NSPoint(x: windowSize.width - 520, y: 0))

        windowController?.window?.contentView?.addSubview(view)

        self.previewView = view
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
