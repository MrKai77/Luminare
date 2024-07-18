//
//  LuminareSettingsWindow.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

// Titlebar height: 50px

import SwiftUI

public class LuminareSettingsWindow: NSWindow, ObservableObject {
    @Published var showPreview: Bool = false
    @Published var hoverPreviewButton: Bool = false

    @Published var showPreviewIcon: Image
    @Published var hidePreviewIcon: Image

    static var identifier = NSUserInterfaceItemIdentifier("LuminareSettingsWindow")
    public var tabs: [SettingsTabGroup]
    static var tint: () -> Color = { .accentColor }

    private let didTabChange: (SettingsTab) -> ()
    var windowDidMoveObserver: NSObjectProtocol?

    static let sidebarWidth: CGFloat = 260
    static let mainViewWidth: CGFloat = 390
    static let previewWidth: CGFloat = 520

    public static var animation: Animation = .smooth(duration: 0.2)
    public static var fastAnimation: Animation = .easeOut(duration: 0.1)

    var closedSize: CGFloat {
        Self.sidebarWidth + Self.mainViewWidth
    }
    var openSize: CGFloat {
        Self.sidebarWidth + Self.mainViewWidth + Self.previewWidth
    }

    var shownPreviews: Set<NSUserInterfaceItemIdentifier> = []

    public init(
        _ tabs: [SettingsTabGroup],
        tint: @escaping () -> Color = { .accentColor },
        didTabChange: @escaping (SettingsTab) -> (),
        showPreviewIcon: Image,
        hidePreviewIcon: Image
    ) {
        self.tabs = tabs
        Self.tint = tint
        self.didTabChange = didTabChange
        self.showPreviewIcon = showPreviewIcon
        self.hidePreviewIcon = hidePreviewIcon

        super.init(
            contentRect: .zero,
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false // If true, background blur will break
        )

        let view = NSHostingView(
            rootView: ContentView(tabs, didTabChange: didTabChange, togglePreview: { self.togglePreview(show: $0) })
                .environment(\.tintColor, LuminareSettingsWindow.tint)
                .environmentObject(self)
        )

        contentView = view
        contentView?.wantsLayer = true
        setContentSize(view.bounds.size)

        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden

        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        toolbar = customToolbar

        // Private API
        setBackgroundBlur(radius: 20)
        identifier = Self.identifier

        alphaValue = 0
        togglePreview(show: true, animate: false)

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
        makeKeyAndOrderFront(self)
        orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        DispatchQueue.main.async {
            self.center()
            self.alphaValue = 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if self.showPreview {
                    self.enableAllShownPreviews()
                }
            }
        }
    }

    // We use this to manually detect the preview toggle button presses, as the invisible titlebar blocks all clicks.
    override public func mouseUp(with event: NSEvent) {
        let previewToggleButtonFrame = NSRect(
            x: closedSize - 38,
            y: frame.height - 38,
            width: 26,
            height: 26
        )

        if previewToggleButtonFrame.contains(event.locationInWindow) {
            togglePreview(show: !showPreview)
        } else {
            super.mouseDown(with: event)
        }
    }

    override public func mouseMoved(with event: NSEvent) {
        let previewToggleButtonFrame = NSRect(
            x: closedSize - 38,
            y: frame.height - 38,
            width: 26,
            height: 26
        )

        if previewToggleButtonFrame.contains(event.locationInWindow) {
            hoverPreviewButton = true
        } else {
            if hoverPreviewButton != false {
                hoverPreviewButton = false
            }

            super.mouseMoved(with: event)
        }
    }

    public func togglePreview(show: Bool, animate: Bool = true) {
        showPreview = show

        let frame = frame
        let newFrame = CGRect(
            origin: .init(x: frame.midX - (show ? openSize / 2 : closedSize / 2), y: frame.minY),
            size: .init(width: show ? openSize : closedSize, height: frame.height)
        )

        if !show {
            self.disableAllPreviews()
        }

        if animate {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.3
                animator().setFrame(newFrame, display: false)
            } completionHandler: {
                if show {
                    self.enableAllShownPreviews()
                }
            }
        } else {
            setFrame(newFrame, display: false)
            enableAllShownPreviews()
        }
    }
}

// MARK: - Previews

public extension LuminareSettingsWindow {
    var previewBounds: NSRect {
        .init(
            x: frame.maxX - Self.previewWidth + 2,
            y: frame.minY,
            width: Self.previewWidth - 2,
            height: frame.height
        )
    }

    func addPreview(content: some View, identifier: String, fullSize: Bool = false) {
        let bounds = previewBounds

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
        addChildWindow(panel, ordered: .above)
    }

    func showPreview(identifier: String) {
        guard
            let windows = childWindows?.compactMap({
                $0.identifier?.rawValue.contains(identifier) ?? false ? $0 : nil
            }),
            !windows.isEmpty
        else {
            return
        }

        for window in windows {
            if frame.width == openSize {
                NSAnimationContext.runAnimationGroup { ctx in
                    ctx.duration = 0.2
                    window.animator().alphaValue = 1
                }
            }

            shownPreviews.insert(window.identifier!)
        }
    }

    func hidePreview(identifier: String) {
        guard
            let windows = childWindows?.filter({ $0.identifier?.rawValue.contains(identifier) ?? false }),
            !windows.isEmpty
        else {
            return
        }

        for window in windows {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.2
                window.animator().alphaValue = 0
            }
            shownPreviews.remove(window.identifier!)
        }
    }

    private func relocatePreview(_ panel: NSWindow) {
        let bounds = previewBounds
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

    private func disableAllPreviews() {
        guard let childWindows else { return }
        for window in childWindows {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.2
                window.animator().alphaValue = 0
            }
        }
    }

    private func enableAllShownPreviews() {
        for identifier in shownPreviews {
            let windows = childWindows?.filter { $0.identifier?.rawValue.contains(identifier.rawValue) ?? false }
            guard let windows else { return }

            for window in windows {
                NSAnimationContext.runAnimationGroup { ctx in
                    ctx.duration = 0.2
                    window.animator().alphaValue = 1
                }

                DispatchQueue.main.async {
                    self.relocatePreview(window)
                }
            }
        }
    }
}
