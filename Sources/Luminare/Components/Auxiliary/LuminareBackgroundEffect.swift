//
//  LuminareBackgroundEffect.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A background effect that matches ``Luminare``.
public struct LuminareBackgroundEffect: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background {
                VisualEffectView(material: .menu, blendingMode: .behindWindow)
                    .edgesIgnoringSafeArea(.top)
                    .allowsHitTesting(false)
            }
    }
}
