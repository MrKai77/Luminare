//
//  LuminareProminentButtonStyle.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized button style that can be tinted.
///
/// To tint the button, use the `.tint()` or `.overrideTint()` modifier.
///
/// ![LuminareProminentButtonStyle](LuminareProminentButtonStyle)
public struct LuminareProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadii) private var cornerRadii
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

    @State private var isHovering: Bool

    public init() {
        self.isHovering = false
    }

    #if DEBUG
        init(
            isHovering: Bool = false
        ) {
            self.isHovering = isHovering
        }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: minHeight)
            .opacity(isEnabled ? 1 : 0.5)
            .modifier(LuminareFilledModifier(
                isHovering: isHovering, isPressed: configuration.isPressed,
                cascading: tint(configuration: configuration)
            ))
            .clipShape(.rect(cornerRadii: cornerRadii))
    }

    private func tint(configuration: Configuration) -> AnyShapeStyle {
        if let role = configuration.role {
            switch role {
            case .cancel, .destructive:
                AnyShapeStyle(.red)
            default:
                AnyShapeStyle(.tint)
            }
        } else {
            AnyShapeStyle(.tint)
        }
    }
}
