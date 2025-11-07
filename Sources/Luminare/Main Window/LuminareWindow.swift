//
//  LuminareWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized window with a materialized appearance.
public class LuminareWindow: NSWindow {
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
        titlebarAppearsTransparent = true
        displayIfNeeded()
        center()
    }
}
