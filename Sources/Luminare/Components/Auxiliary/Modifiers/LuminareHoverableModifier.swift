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
public struct LuminareHoverableModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding

    private let isPressed: Bool
    private let fill: AnyShapeStyle, hovering: AnyShapeStyle, pressed: AnyShapeStyle

    @State private var isHovering: Bool

    public init(
        isPressed: Bool = false,
        fill: some ShapeStyle,
        hovering: some ShapeStyle,
        pressed: some ShapeStyle
    ) {
        self.isPressed = isPressed
        self.fill = .init(fill)
        self.hovering = .init(hovering)
        self.pressed = .init(pressed)
        self.isHovering = false
    }

    public init(
        isPressed: Bool = false,
        cascading: some ShapeStyle
    ) {
        self.init(
            isPressed: isPressed,
            fill: cascading.opacity(0.15),
            hovering: cascading.opacity(0.25),
            pressed: cascading.opacity(0.4)
        )
    }

    public init(
        isPressed: Bool = false,
        pressed: some ShapeStyle
    ) {
        self.init(
            isPressed: isPressed,
            fill: .clear, hovering: pressed, pressed: pressed
        )
    }

    public init(
        isPressed: Bool = false
    ) {
        self.init(
            isPressed: isPressed,
            pressed: .quinary
        )
    }

    #if DEBUG
        init(
            isPressed: Bool = false, isHovering: Bool = false,
            fill: some ShapeStyle, hovering: some ShapeStyle,
            pressed: some ShapeStyle
        ) {
            self.isPressed = isPressed
            self.fill = .init(fill)
            self.hovering = .init(hovering)
            self.pressed = .init(pressed)
            self.isHovering = isHovering
        }

        init(
            isPressed: Bool = false, isHovering: Bool = false,
            cascading: some ShapeStyle
        ) {
            self.init(
                isPressed: isPressed, isHovering: isHovering,
                fill: cascading.opacity(0.15),
                hovering: cascading.opacity(0.25),
                pressed: cascading.opacity(0.4)
            )
        }

        init(
            isPressed: Bool = false, isHovering: Bool = false,
            pressed: some ShapeStyle
        ) {
            self.init(
                isPressed: isPressed, isHovering: isHovering,
                fill: .clear, hovering: pressed, pressed: pressed
            )
        }

        init(
            isPressed: Bool = false, isHovering: Bool = false
        ) {
            self.init(
                isPressed: isPressed, isHovering: isHovering,
                pressed: .quinary
            )
        }
    #endif

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .modifier(LuminareAspectRatioModifier())
            .opacity(isEnabled ? 1 : 0.5)
            .modifier(
                LuminareFilledModifier(
                    isHovering: isHovering,
                    isPressed: isPressed,
                    fill: fill,
                    hovering: hovering,
                    pressed: pressed
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
