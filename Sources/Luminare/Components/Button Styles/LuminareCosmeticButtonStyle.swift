//
//  LuminareCosmeticButtonStyle.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized button style that accepts an additional image for hovering.
///
/// Typically used for complex layouts with a custom avatar.
/// However, the content is not constrained in any specific format.
///
/// ![LuminareCosmeticButtonStyle](LuminareCosmeticButtonStyle)
public struct LuminareCosmeticButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadii) private var cornerRadii

    @ViewBuilder private var icon: Image

    @State private var isHovering: Bool

    /// Initializes a ``LuminareCosmeticButtonStyle``.
    ///
    /// - Parameters:
    ///   - icon: the trailing aligned `Image` to display while hovering.
    public init(
        icon: Image
    ) {
        self.icon = icon
        self.isHovering = false
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: minHeight)
            .opacity(isEnabled ? 1 : 0.5)
            .modifier(LuminareFilledModifier(
                isHovering: isHovering, isPressed: configuration.isPressed,
                fill: .clear, hovering: .quaternary.opacity(0.7),
                pressed: .quaternary
            ))
            .overlay {
                HStack {
                    Spacer()

                    icon
                        .opacity(isHovering ? 1 : 0)
                }
                .padding(24)
                .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadii: cornerRadii))
            .onHover { isHovering in
                self.isHovering = isHovering
            }
            .animation(animationFast, value: isHovering)
    }
}
