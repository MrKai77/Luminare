//
//  LuminareWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized window with a materialized appearance.
public class LuminareWindow: NSWindow {
    private var initializationTime: Date

    /// Initializes a ``LuminareWindow``.
    ///
    /// - Parameters:
    ///   - content: the content view of the window, wrapped in a ``LuminareView``.
    public init(content: @escaping () -> some View) {
        self.initializationTime = .now

        super.init(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView, .closable, .resizable],
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
        alphaValue = 0
    }

    /// Shows this window.
    /// This action activates the current application and orders the window to the frontmost.
    public func show() {
        orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1
        }
    }
}

// MARK: - Add this to your project if a transparent background is needed
/*

// Set the radius like this:

try? setBackgroundBlur(radius: Int(blurRadius))
backgroundColor = .white.withAlphaComponent(0.001)
ignoresMouseEvents = false

extension LuminareWindow {
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
}

typealias CGSConnectionID = UInt32

@_silgen_name("CGSDefaultConnectionForThread")
func CGSDefaultConnectionForThread() -> CGSConnectionID?

@_silgen_name("CGSSetWindowBackgroundBlurRadius") @discardableResult
func CGSSetWindowBackgroundBlurRadius(
    _ connection: CGSConnectionID,
    _ windowNum: NSInteger,
    _ radius: Int
) -> OSStatus
*/
