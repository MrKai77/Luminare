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
public struct LuminareHoverableModifier<F, H, P, A, B>: ViewModifier where F: ShapeStyle, H: ShapeStyle, P: ShapeStyle, A: ShapeStyle, B: ShapeStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding

    private let isPressed: Bool
    private let fillStyle: LuminareFilledStyle<F, H, P>
    private let borderStyle: LuminareBorderedStyle<A,B>
    @State private var isHovering: Bool = false

    public init(
        isPressed: Bool = false,
        fillStyle: LuminareFilledStyle<F, H, P> = .default,
        borderStyle: LuminareBorderedStyle<A,B> = .default
    ) {
        self.isPressed = isPressed
        self.fillStyle = fillStyle
        self.borderStyle = borderStyle
    }

    public init(
        isPressed: Bool = false
    ) where F == HierarchicalShapeStyle, H == HierarchicalShapeStyle, P == HierarchicalShapeStyle, A == HierarchicalShapeStyle, B == HierarchicalShapeStyle {
        self.init(
            isPressed: isPressed,
            isHovering: false
        )
    }

    // Note: not public!
    init(
        isPressed: Bool = false,
        isHovering: Bool = false
    ) where F == HierarchicalShapeStyle, H == HierarchicalShapeStyle, P == HierarchicalShapeStyle, A == HierarchicalShapeStyle, B == HierarchicalShapeStyle {
        self.isPressed = isPressed
        self.isHovering = isHovering
        self.fillStyle = .default
        self.borderStyle = .default
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
                    style: fillStyle
                )
            )
            .modifier(
                LuminareBorderedModifier(
                    isHovering: isHovering,
                    style: borderStyle
                )
            )
            .onHover { isHovering in
                withAnimation(animationFast) {
                    self.isHovering = isHovering
                }
            }
    }
}
