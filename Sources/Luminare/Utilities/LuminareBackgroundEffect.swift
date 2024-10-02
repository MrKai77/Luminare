//
//  LuminareBackgroundEffect.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminareBackgroundEffect: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .frame(maxHeight: .infinity)
            .background {
                VisualEffectView(material: .menu, blendingMode: .behindWindow)
                    .edgesIgnoringSafeArea(.top)
            }
    }
}

public extension View {
    func luminareBackground() -> some View {
        modifier(LuminareBackgroundEffect())
    }
}
