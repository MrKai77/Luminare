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
    public var windowController: NSWindowController?
    public var tabs: [SettingsTabGroup]
    static var tint: () -> Color = { .accentColor }

    private let didTabChange: (SettingsTab) -> Void

    public var previewBounds: NSRect? {
        guard let window = windowController?.window else { return nil }
        let previewWidth: CGFloat = 520

        return .init(
            x: window.frame.maxX - previewWidth,
            y: window.frame.minY,
            width: previewWidth,
            height: window.frame.height
        )
    }

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
        guard let controller = windowController else { return }

        controller.window?.center()
        controller.window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    public func initializeWindow() {
        guard windowController?.window == nil else { return }

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

        self.windowController = .init(window: window)
    }

    public func deinitWindow() {
        self.windowController?.window?.close()
        self.windowController = nil
    }

    public func addPreview<Content: View>(content: Content, identifier: String, fullSize: Bool = false) {
        guard
            let window = self.windowController?.window,
            let bounds = self.previewBounds
        else {
            return
        }

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        panel.hasShadow = false
        panel.backgroundColor = .clear
        if fullSize {
            panel.contentView = NSHostingView(rootView: content.frame(width: bounds.width, height: bounds.height))
        } else {
            panel.contentView = NSHostingView(rootView: content)
        }
        panel.alphaValue = 0
        panel.identifier = .init("LuminareSettingsPreview\(identifier)")

        let windowFrame = window.frame

        let panelSize = panel.frame.size
        let newSize = CGSize(
            width: min(bounds.width, panelSize.width),
            height: min(bounds.height, panelSize.height)
        )
        let newOrigin = CGPoint(
            x: bounds.midX - newSize.width / 2,
            y: bounds.midY - newSize.height / 2
        )
        panel.setFrame(
            .init(origin: newOrigin, size: newSize),
            display: false
        )
        window.addChildWindow(panel, ordered: .above)
    }

    public func showPreview(identifier: String) {
        guard
            let windows = windowController?.window?.childWindows?.compactMap({
                $0.identifier?.rawValue.contains(identifier) ?? false ? $0 : nil
            }),
            !windows.isEmpty
        else {
            return
        }
        
        for window in windows {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.3
                window.animator().alphaValue = 1
            })
        }
    }

    public func hidePreview(identifier: String) {
        guard
            let windows = windowController?.window?.childWindows?.compactMap({
                $0.identifier?.rawValue.contains(identifier) ?? false ? $0 : nil
            }),
            !windows.isEmpty
        else {
            return
        }

        for window in windows {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.2
                window.animator().alphaValue = 0
            })
        }
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
