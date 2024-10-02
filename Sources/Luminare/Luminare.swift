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
        content: @escaping () -> Content,
        blurRadius: CGFloat? = nil
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

    var isResizing: Bool = false
    public override func setContentSize(_ size: NSSize) {
        if initializationTime.timeIntervalSinceNow > -0.2 || frame.width * frame.height == 0 {
            super.setContentSize(size)
            return
        }

        if isResizing {
            return
        }

        isResizing = true

        let origin = CGPoint(
            x: frame.midX - size.width / 2,
            y: frame.midY - size.height / 2
        )
        var newFrame = CGRect(
            origin: origin,
            size: size
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.72, 0, 0.28, 1)
            super.animator().setFrame(newFrame, display: true)
        } completionHandler: {
            self.isResizing = false
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
