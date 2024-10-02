//
//  Luminare.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminareConstants {
    public static var tint: () -> Color = { .accentColor }
    public static var animation: Animation = .smooth(duration: 0.2)
    public static var fastAnimation: Animation = .easeOut(duration: 0.1)
}

public class LuminareWindow: NSWindow {
    private var initializationTime: Date

    public init<Content>(
        blurRadius: CGFloat? = nil,
        content: @escaping () -> Content
    ) where Content: View {
        self.initializationTime = .now

        super.init(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false // If true, background blur will break
        )

        let view = NSHostingView(rootView: content()
            .environment(\.tintColor, LuminareConstants.tint)
            .environment(\.luminareWindow, self)
            .buttonStyle(LuminareButtonStyle())
            .tint(LuminareConstants.tint())
        )

        contentView = view

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView!.leadingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: contentView!.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView!.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor)
        ])

        toolbarStyle = .unified
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = NSToolbar()

        if let blurRadius {
            try? setBackgroundBlur(radius: Int(blurRadius))
            backgroundColor = .white.withAlphaComponent(0.001)
            ignoresMouseEvents = false
        }

        alphaValue = 0
    }

    public func show() {
        orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1
        }

        DispatchQueue.main.async {
            // Explanation:
            // Since we disable translatesAutoresizingMaskIntoConstraints, some window decorations become glitchy (not sure why).
            // As soon as the window resizes, this bug magically fixes itself. So we do that here.
            let originalSize = self.frame.size
            super.setContentSize(CGSize(width: originalSize.width - 1, height: originalSize.height - 1))
            super.setContentSize(originalSize)
        }
    }

    func setBackgroundBlur(radius: Int) throws {
        guard let connection = CGSDefaultConnectionForThread() else {
            throw NSError(
                domain: "com.Luminare.NSWindow",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Error getting default connection"]
            )
        }

        let status = CGSSetWindowBackgroundBlurRadius(connection, windowNumber, radius)

        if status != noErr {
            throw NSError(
                domain: "com.Luminare.NSWindow",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Error setting blur radius: \(status)"]
            )
        }
    }

    var currentResizeEvent: UUID? = nil
    public override func setContentSize(_ size: NSSize) {
        if initializationTime.timeIntervalSinceNow > -0.2 || frame.width * frame.height == 0 {
            super.setContentSize(size)
            return
        }

        currentResizeEvent = UUID()

        var newFrame = NSRect(
            origin: frame.origin,
            size: size
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.72, 0, 0.28, 1)
            super.animator().setFrame(newFrame, display: true)
        } completionHandler: {
            self.currentResizeEvent = nil
        }
    }
}

// MARK: - Private APIs

typealias CGSConnectionID = UInt32

@_silgen_name("CGSDefaultConnectionForThread")
func CGSDefaultConnectionForThread() -> CGSConnectionID?

@_silgen_name("CGSSetWindowBackgroundBlurRadius") @discardableResult
func CGSSetWindowBackgroundBlurRadius(
    _ connection: CGSConnectionID,
    _ windowNum: NSInteger,
    _ radius: Int
) -> OSStatus
