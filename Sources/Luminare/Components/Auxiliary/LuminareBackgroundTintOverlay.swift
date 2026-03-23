//
//  LuminareBackgroundTintOverlay.swift
//  Luminare
//
//  Created by Adon Omeri on 2025-03-24.
//

import SwiftUI

/// The tint overlay applied on top of any `VisualEffectView` inside Luminare backgrounds.
struct LuminareBackgroundTintOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .foregroundStyle(.tint)
            .opacity(colorScheme == .light ? 0.025 : 0.1)
            .blendMode(.multiply)
    }
}
