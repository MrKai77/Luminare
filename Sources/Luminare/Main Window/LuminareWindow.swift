//
//  LuminareWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized window with a materialized appearance.
public class LuminareWindow: NSWindow {
    private var animator: LuminareWindowAnimator!

    /// Initializes a ``LuminareWindow``.
    ///
    /// - Parameters:
    ///   - content: the content view of the window, wrapped in a ``LuminareView``.
    public init(content: @escaping () -> some View) {
        super.init(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false
        )

        self.animator = LuminareWindowAnimator(window: self)

        let view = NSHostingView(
            rootView: LuminareView(content: content)
                .environment(\.luminareWindow, self)
        )

        contentView = view
        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        
        let toolbar = NSToolbar()
        toolbar.showsBaselineSeparator = false
        if #available(macOS 15.0, *) {
            toolbar.allowsDisplayModeCustomization = false
        }
        self.toolbar = toolbar
        
        displayIfNeeded()
    }

    func setSize(size: CGSize, animate: Bool) {
        guard size.width > 0, size.height > 0 else { return }

        animator.cancel()

        var frame = NSRect(
            origin: frame.origin,
            size: CGSize(
                width: size.width,
                height: size.height + 52 // 52 is the title bar height
            )
        )

        if let screenFrame = screen?.visibleFrame {
            if frame.minX < screenFrame.minX {
                frame.origin.x = screenFrame.minX
            }

            if frame.minY < screenFrame.minY {
                frame.origin.y = screenFrame.minY
            }

            if frame.maxX > screenFrame.maxX {
                frame.origin.x = screenFrame.maxX - frame.width
            }

            if frame.maxY > screenFrame.maxY {
                frame.origin.y = screenFrame.maxY - frame.height
            }
        }

        if animate, isVisible {
            animator.animate(to: frame, duration: 0.3) { t in
                1 - pow(1 - t, 3)
            }
        } else {
            setFrame(frame, display: true)
        }
    }
}
