//
//  LuminareBackgroundEffectModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A background effect that matches ``Luminare``.
public struct LuminareBackgroundEffectModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorscheme

    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    VisualEffectView(
                        material: .menu,
                        blendingMode: .behindWindow
                    )

                    Rectangle()
                        .foregroundStyle(.tint)
                        .opacity(colorscheme == .light ? 0.025 : 0.1)
                        .blendMode(.multiply)
                }
                .compositingGroup()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
    }
}
