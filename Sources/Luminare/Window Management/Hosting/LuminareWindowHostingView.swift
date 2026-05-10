//
//  LuminareWindowHostingView.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-10.
//

import SwiftUI

final class LuminareWindowHostingView<Content>: NSHostingView<Content> where Content: View {
    override var safeAreaRect: NSRect {
        bounds
    }

    override var safeAreaInsets: NSEdgeInsets {
        .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    override var additionalSafeAreaInsets: NSEdgeInsets {
        get {
            .init(top: 0, left: 0, bottom: 0, right: 0)
        }
        set {}
    }
}
