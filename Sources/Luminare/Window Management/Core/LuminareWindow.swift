//
//  LuminareWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized window with a materialized appearance.
public class LuminareWindow: LuminareStyledWindow {
    private let resizeAnimator: LuminareWindowResizeAnimator
    private let windowCanBecomeMain: Bool
    private let closesOnDefocus: Bool
    private let initialOrigin: ((CGRect) -> CGPoint)?
    private let onClose: (() -> ())?
    private var hasPositionedWindow = false

    public convenience init(
        titleBarButtonConfiguration: LuminareTitleBarButtonConfiguration? = .default,
        cornerRadius: CGFloat = LuminareStyledWindow.defaultCornerRadius,
        content: @escaping () -> some View
    ) {
        self.init(
            _internalConfiguration: (),
            titleBarButtonConfiguration: titleBarButtonConfiguration,
            cornerRadius: cornerRadius,
            content: content
        )
    }

    /// Initializes a ``LuminareWindow``.
    ///
    /// - Parameters:
    ///   - titleBarButtonConfiguration: The titlebar button padding and spacing.
    ///   - cornerRadius: The window corner radius.
    ///   - level: The AppKit window level.
    ///   - canBecomeMain: Whether the window can become the main window.
    ///   - closesOnDefocus: Whether the window closes when it resigns key status.
    ///   - dragRegionHeight: A top-edge region that can drag the window.
    ///   - initialOrigin: Optional initial origin provider after first sizing.
    ///   - onClose: A callback invoked when the window closes.
    ///   - content: the content view of the window, wrapped in a ``LuminareView``.
    init(
        _internalConfiguration _: () = (),
        titleBarButtonConfiguration: LuminareTitleBarButtonConfiguration? = .default,
        cornerRadius: CGFloat = LuminareStyledWindow.defaultCornerRadius,
        canBecomeMain: Bool = true,
        closesOnDefocus: Bool = false,
        initialOrigin: ((CGRect) -> CGPoint)? = nil,
        onClose: (() -> ())? = nil,
        content: @escaping () -> some View
    ) {
        self.resizeAnimator = .init()
        self.windowCanBecomeMain = canBecomeMain
        self.closesOnDefocus = closesOnDefocus
        self.initialOrigin = initialOrigin
        self.onClose = onClose

        super.init(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false
        )

        let luminareView = LuminareWindowHostingView(
            rootView: LuminareWindowMeasuredContentView(content: content) { [weak self] in
                self?.setSize($0)
            }
        )
        let view = LuminareWindowHostingContainerView(hostedView: luminareView)

        self.titleBarButtonConfiguration = titleBarButtonConfiguration
        luminareCornerRadius = cornerRadius
        alphaValue = 0
        contentView = view
        contentView?.wantsLayer = true
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        layoutIfNeeded()
        resizeAnimator.onUpdate = { [weak self] size in
            self?.applyContentSize(size)
        }

        DispatchQueue.main.async { [weak self, weak luminareView] in
            guard let self, !self.hasPositionedWindow, let luminareView else {
                return
            }

            snapToInitialSize(luminareView.fittingSize)
        }
    }

    func setSize(_ size: CGSize) {
        let newSize = CGSize(
            width: ceil(size.width),
            height: ceil(size.height)
        )

        guard newSize.width > 0, newSize.height > 0 else {
            return
        }

        if resizeAnimator.hasNoTarget {
            snapToInitialSize(newSize)
            return
        }

        resizeAnimator.animate(to: newSize)
    }

    private func snapToInitialSize(_ size: CGSize) {
        let newSize = CGSize(
            width: ceil(size.width),
            height: ceil(size.height)
        )

        guard newSize.width > 0, newSize.height > 0 else {
            return
        }

        resizeAnimator.snap(to: newSize)
        applyContentSize(newSize)
        if !hasPositionedWindow {
            if let initialOrigin {
                setFrameOrigin(initialOrigin(frame))
            } else {
                center()
            }
            alphaValue = 1
            hasPositionedWindow = true
        }
    }

    private func applyContentSize(_ size: CGSize) {
        let newOrigin = NSPoint(
            x: frame.origin.x,
            y: frame.maxY - size.height
        )

        setFrame(.init(origin: newOrigin, size: size), display: true)
    }

    override public func close() {
        resizeAnimator.stop()
        super.close()
        onClose?()
    }

    override public var canBecomeMain: Bool {
        windowCanBecomeMain
    }

    override public func resignKey() {
        super.resignKey()
        if closesOnDefocus {
            close()
        }
    }
}
