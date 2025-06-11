//
//  LuminareFilledModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

public struct LuminareFilledModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareHasBackground) private var hasBackground
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

    private let isHovering: Bool, isPressed: Bool
    private let fill: AnyShapeStyle, hovering: AnyShapeStyle,
                pressed: AnyShapeStyle

    public init(
        isHovering: Bool = false, isPressed: Bool = false,
        fill: some ShapeStyle, hovering: some ShapeStyle,
        pressed: some ShapeStyle
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.fill = .init(fill)
        self.hovering = .init(hovering)
        self.pressed = .init(pressed)
    }

    public init(
        isHovering: Bool = false, isPressed: Bool = false,
        cascading: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering, isPressed: isPressed,
            fill: cascading.opacity(0.15),
            hovering: cascading.opacity(0.25),
            pressed: cascading.opacity(0.4)
        )
    }

    public init(
        isHovering: Bool = false, isPressed: Bool = false,
        pressed: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering, isPressed: isPressed,
            fill: .clear, hovering: pressed, pressed: pressed
        )
    }

    public init(
        isHovering: Bool = false, isPressed: Bool = false
    ) {
        self.init(
            isHovering: isHovering, isPressed: isPressed,
            pressed: .quinary
        )
    }

    public func body(content: Content) -> some View {
        if hasBackground {
            content
                .background(with: material) {
                    Group {
                        if isEnabled {
                            if isPressed {
                                Rectangle()
                                    .foregroundStyle(pressed)
                            } else if highlightOnHover, isHovering {
                                Rectangle()
                                    .foregroundStyle(hovering)
                            } else {
                                Rectangle()
                                    .foregroundStyle(fill)
                            }
                        } else {
                            Rectangle()
                                .foregroundStyle(fill)
                        }
                    }
                    .opacity(isEnabled ? 1 : 0.5)
                }
        } else {
            content
        }
    }
}
