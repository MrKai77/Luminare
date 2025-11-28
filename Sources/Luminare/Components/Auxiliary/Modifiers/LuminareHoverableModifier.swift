//
//  LuminareHoverableModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized modifier that constructs a bordered appearance while hovering.
///
/// Combines both of `LuminareFilledModifier` and `LuminareBorderedModifier`.
public struct LuminareHoverableModifier<F, H, P>: ViewModifier where F: ShapeStyle, H: ShapeStyle, P: ShapeStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding

    private let isPressed: Bool
    private let filledStyle: LuminareFilledStyle<F, H, P>
    @State private var isHovering: Bool = false

    public init(
        isPressed: Bool = false,
        filledStyle: LuminareFilledStyle<F, H, P>
    ) {
        self.isPressed = isPressed
        self.filledStyle = filledStyle
    }

    public init(
        isPressed: Bool = false
    ) where F == Color, H == Color, P == HierarchicalShapeStyle {
        self.init(
            isPressed: isPressed,
            isHovering: false
        )
    }

    // Note: not public!
    init(
        isPressed: Bool = false,
        isHovering: Bool = false
    ) where F == Color, H == Color, P == HierarchicalShapeStyle {
        self.isPressed = isPressed
        self.isHovering = isHovering
        self.filledStyle = .init(whenPressed: .quinary)
    }

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .modifier(LuminareAspectRatioModifier())
            .opacity(isEnabled ? 1 : 0.5)
            .modifier(
                LuminareFilledModifier(
                    isHovering: isHovering,
                    isPressed: isPressed,
                    style: filledStyle
                )
            )
            .modifier(
                LuminareBorderedModifier(
                    isHovering: isHovering
                )
            )
            .onHover { isHovering in
                withAnimation(animationFast) {
                    self.isHovering = isHovering
                }
            }
    }
}
