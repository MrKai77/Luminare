//
//  LuminareSettingsWindow.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

// Titlebar height: 50px

import SwiftUI

public class LuminareSettingsWindow: NSWindow {
    static var identifier = NSUserInterfaceItemIdentifier("LuminareSettingsWindow")
    public var tabs: [SettingsTabGroup]
    static var tint: () -> Color = { .accentColor }

    private let didTabChange: (SettingsTab) -> ()
    var windowDidMoveObserver: NSObjectProtocol?

    static let sidebarWidth: CGFloat = 260
    static let mainViewWidth: CGFloat = 390
    static let previewWidth: CGFloat = 520

    public var previewBounds: NSRect? {
        guard let window = windowController?.window else { return nil }

        return .init(
            x: window.frame.maxX - Self.previewWidth,
            y: window.frame.minY,
            width: Self.previewWidth,
            height: window.frame.height
        )
    }

    public init(
        _ tabs: [SettingsTabGroup],
        tint: @escaping () -> Color = { .accentColor },
        didTabChange: @escaping (SettingsTab) -> ()
    ) {
        self.tabs = tabs
        Self.tint = tint
        self.didTabChange = didTabChange

        super.init(
            contentRect: .zero,
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false // If true, background blur will break
        )

        let view = NSHostingView(
            rootView: ContentView(tabs, didTabChange: didTabChange, togglePreview: togglePreview(show:))
                .environment(\.tintColor, LuminareSettingsWindow.tint)
        )

        contentView = view
        contentView?.wantsLayer = true

        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden

//        let customToolbar = NSToolbar()
//        customToolbar.showsBaselineSeparator = false
//        toolbar = customToolbar

        // Private API
        setBackgroundBlur(radius: 20)
        identifier = Self.identifier

        self.windowDidMoveObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: nil,
            queue: .main
        ) { _ in
            guard let children = self.childWindows else {
                return
            }

            children.forEach { self.relocatePreview($0) }
        }
    }

    public func show() {
        center()
        makeKeyAndOrderFront(self)
        orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    public func togglePreview(show: Bool) {
        let closedSize = Self.sidebarWidth + Self.mainViewWidth
        let openSize = Self.sidebarWidth + Self.mainViewWidth + Self.previewWidth

        let frame = frame
        let newFrame = CGRect(
            origin: .init(x: frame.midX - (show ? openSize / 2 : closedSize / 2), y: frame.minY),
            size: .init(width: show ? openSize : closedSize, height: frame.height)
        )

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            animator().setFrame(newFrame, display: false)
        }
    }

    public func deinitWindow() {
        if let windowDidMoveObserver {
            NotificationCenter.default.removeObserver(windowDidMoveObserver)
        }
        windowDidMoveObserver = nil

        close()
    }
}

// MARK: - Previews

public extension LuminareSettingsWindow {
    func addPreview(content: some View, identifier: String, fullSize: Bool = false) {
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

    func showPreview(identifier: String) {
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

    func hidePreview(identifier: String) {
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
