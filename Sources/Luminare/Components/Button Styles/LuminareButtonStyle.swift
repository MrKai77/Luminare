//
//  LuminareButtonStyle.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized button style.
///
/// ![LuminareButtonStyle](LuminareButtonStyle)
public struct LuminareButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadii) private var cornerRadii

    @State private var isHovering: Bool = false
    private let tinted: Bool

    public init(tinted: Bool = false) {
        self.tinted = tinted
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: .infinity)
            .opacity(isEnabled ? 1 : 0.5)
            .modifier(
                LuminareFilledModifier(
                    isHovering: isHovering,
                    isPressed: configuration.isPressed,
                    style: fillStyle(configuration: configuration)
                )
            )
            .clipShape(.rect(cornerRadii: cornerRadii))
            .onHover { isHovering = $0 }
    }

    private func fillStyle(configuration: Configuration) -> LuminareFilledStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle> {
        let tint = buttonTint(configuration: configuration)

        return .init(
            normal: AnyShapeStyle(tint.opacity(0.15)),
            hovering: AnyShapeStyle(tint.opacity(0.25)),
            pressed: AnyShapeStyle(tint.opacity(0.4))
        )
    }

    private func buttonTint(configuration: Configuration) -> AnyShapeStyle {
        if tinted {
            return AnyShapeStyle(.tint)
        }

        if let role = configuration.role,
           role == .destructive || role == .cancel {
            return AnyShapeStyle(.red)
        }

        return AnyShapeStyle(.tertiary)
    }
}
