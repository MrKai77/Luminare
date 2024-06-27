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

    private let didTabChange: (SettingsTab) -> ()
    var windowDidMoveObserver: NSObjectProtocol?

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
        didTabChange: @escaping (SettingsTab) -> ()
    ) {
        self.tabs = tabs
        LuminareSettingsWindow.tint = tint
        self.didTabChange = didTabChange
    }

    public func show() {
        guard let controller = windowController else { return }

        DispatchQueue.main.async {
            controller.window?.center()
            controller.window?.makeKeyAndOrderFront(self)
            controller.window?.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    public func initializeWindow() {
        guard windowController?.window == nil else { return }

        let view = NSHostingView(
            rootView: ContentView(tabs, didTabChange: didTabChange)
                .environment(\.tintColor, LuminareSettingsWindow.tint)
        )

        let window = NSWindow(
            contentRect: view.bounds,
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false // If true, background blur will break
        )

        window.contentView = view
        window.contentView?.wantsLayer = true

        window.toolbarStyle = .unified
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        window.toolbar = customToolbar

        // Private API
        window.setBackgroundBlur(radius: 20)
        window.identifier = LuminareSettingsWindow.identifier

        windowController = .init(window: window)

        windowDidMoveObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: nil,
            queue: .main
        ) { _ in
            guard let children = self.windowController?.window?.childWindows else {
                return
            }

            children.forEach { self.relocatePreview($0) }
        }
    }

    public func deinitWindow() {
        if let windowDidMoveObserver {
            NotificationCenter.default.removeObserver(windowDidMoveObserver)
        }
        windowDidMoveObserver = nil

        windowController?.window?.close()
        windowController = nil
    }

    public func addPreview(content: some View, identifier: String, fullSize: Bool = false) {
        guard
            let window = windowController?.window,
            let bounds = previewBounds
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
        panel.ignoresMouseEvents = true
        panel.identifier = .init("LuminareSettingsPreview\(identifier)")

        relocatePreview(panel)
        window.addChildWindow(panel, ordered: .above)
    }

    private func relocatePreview(_ panel: NSWindow) {
        guard let bounds = previewBounds else {
            return
        }
        let panelFrame = panel.frame

        let newSize = CGSize(
            width: min(bounds.width, panelFrame.width),
            height: min(bounds.height, panelFrame.height)
        )
        let newOrigin = CGPoint(
            x: bounds.midX - newSize.width / 2,
            y: bounds.midY - newSize.height / 2
        )

        guard panelFrame.origin != newOrigin else {
            return
        }

        panel.setFrame(
            .init(origin: newOrigin, size: newSize),
            display: false
        )
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
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.3
                window.animator().alphaValue = 1
            }
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
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.2
                window.animator().alphaValue = 0
            }
        }
    }
}
