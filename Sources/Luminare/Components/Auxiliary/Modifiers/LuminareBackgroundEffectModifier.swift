//
//  LuminareBackgroundEffectModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A background effect that matches ``Luminare``.
public struct LuminareBackgroundEffectModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background {
                VisualEffectView(
                    material: .menu,
                    blendingMode: .behindWindow,
                    state: .active
                )
                .edgesIgnoringSafeArea(.top)
                .allowsHitTesting(false)
            }
    }
}
