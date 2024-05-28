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

    public func addPreview<Content: View>(content: Content, identifier: String = "") {
        DispatchQueue.main.async {
            guard let window = self.windowController?.window else {
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
            panel.contentView = NSHostingView(rootView: content)
            panel.alphaValue = 0
            panel.identifier = .init("LuminareSettingsPreview\(identifier)")

            let windowFrame = window.frame
            let previewWidth: CGFloat = 520
            let bounds = CGRect(
                x: windowFrame.maxX - previewWidth,
                y: windowFrame.minY,
                width: previewWidth,
                height: windowFrame.height
            )

            let panelSize = panel.frame.size
            let newSize = CGSize(
                width: min(previewWidth, panelSize.width),
                height: min(previewWidth, panelSize.height)
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

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                panel.animator().alphaValue = 1
            }
        }
    }

    public func removePreview(identifier: String) {
        guard
            let windows = windowController?.window?.childWindows?.compactMap({
                $0.identifier?.rawValue == "LuminareSettingsPreview\(identifier)" ? $0 : nil
            }),
            !windows.isEmpty
        else {
            return
        }

        print(windows)

        for window in windows {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.1
                window.animator().alphaValue = 0
            }, completionHandler: {
                window.close()
            })
        }
    }

    public var previewViews: [String] {
        let windows = windowController?.window?.childWindows?.compactMap({
            $0.identifier?.rawValue.contains("LuminareSettingsPreview") ?? false ? $0 : nil
        }) ?? []

        let result: [String] = windows.compactMap {
            $0.identifier?.rawValue.replacingOccurrences(of: "LuminareSettingsPreview", with: "")
        }

        return result
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
