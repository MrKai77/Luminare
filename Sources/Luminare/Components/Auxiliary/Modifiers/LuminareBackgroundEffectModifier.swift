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
    @Environment(\.luminareBackgroundBlurStyle) private var blurStyle

    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    if blurStyle == .regular {
                        VisualEffectView(
                            material: .menu,
                            blendingMode: .behindWindow
                        )

                        LuminareBackgroundTintOverlay()
                    }
                }
                .compositingGroup()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
    }
}
