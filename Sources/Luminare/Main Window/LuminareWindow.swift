//
//  LuminareWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized window with a materialized appearance.
public class LuminareWindow: NSWindow {
    private var currentAnimation: LuminareWindowAnimation?

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

        let view = NSHostingView(
            rootView: LuminareView(content: content)
                .environment(\.luminareWindow, self)
        )

        contentView = view
        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = NSToolbar()
    }

    func setSize(size: CGSize, animate: Bool) {
        guard size.width > 0, size.height > 0 else { return }

        currentAnimation?.stop()

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

        if animate {
            currentAnimation = LuminareWindowAnimation(self, frame)
            currentAnimation?.start()
        } else {
            setFrame(frame, display: true)
        }
    }
}

// MARK: - NSWindow Animation

// Vustom `NSWindow` resize animation so that it can be stopped midway
class LuminareWindowAnimation: NSAnimation {
    let window: NSWindow
    let targetFrame: NSRect

    init(_ window: NSWindow, _ targetFrame: NSRect) {
        self.window = window
        self.targetFrame = targetFrame
        super.init(duration: 0.5, animationCurve: .easeOut)
        super.animationBlockingMode = .nonblocking // allows the window to redraw contents while animating
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var currentProgress: NSAnimation.Progress {
        didSet {
            // The last frame of this `NSAnimation` looks a little stuttery,
            // so we multiply the progress by 1.01, and then make sure the last
            // frame doesn't draw
            let progress = CGFloat(currentProgress * 1.01)
            guard progress < 1 else {
                return
            }

            let currentFrame = NSRect(
                x: window.frame.origin.x + (targetFrame.origin.x - window.frame.origin.x) * progress,
                y: window.frame.origin.y + (targetFrame.origin.y - window.frame.origin.y) * progress,
                width: window.frame.width + (targetFrame.width - window.frame.width) * progress,
                height: window.frame.height + (targetFrame.height - window.frame.height) * progress
            )

            window.setFrame(currentFrame, display: false)
        }
    }
}
