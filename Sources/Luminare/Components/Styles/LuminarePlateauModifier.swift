//
//  LuminarePlateauModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2025-11-28.
//

import SwiftUI

public struct LuminarePlateauModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.luminareCornerRadii) private var cornerRadii

    private let isPressed: Bool
    private let isHovering: Bool
    private let overrideFillStyle: LuminareFilledStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
    private let overrideBorderStyle: LuminareBorderedStyle<AnyShapeStyle, AnyShapeStyle>?

    public init(
        isPressed: Bool = false,
        isHovering: Bool = false,
        overrideFillStyle: LuminareFilledStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
        overrideBorderStyle: LuminareBorderedStyle<AnyShapeStyle, AnyShapeStyle>? = nil
    ) {
        self.isPressed = isPressed
        self.isHovering = isHovering
        self.overrideFillStyle = overrideFillStyle
        self.overrideBorderStyle = overrideBorderStyle
    }

    public func body(content: Content) -> some View {
        content
            .compositingGroup()
            .opacity(isEnabled ? 1 : 0.5)
            .background {
                if let overrideFillStyle {
                    LuminareFill(isHovering: isHovering, isPressed: isPressed, style: overrideFillStyle)
                } else {
                    LuminareFill(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        style: .init(
                            normal: colorScheme == .light ? AnyShapeStyle(.white.opacity(0.7)) : AnyShapeStyle(.quinary),
                            hovering: colorScheme == .light ? .quinary : .quaternary,
                            pressed: colorScheme == .light ? AnyShapeStyle(.quaternary) : AnyShapeStyle(.tertiary.opacity(0.6))
                        )
                    )
                }

                if let overrideBorderStyle {
                    LuminareBorder(isHovering: isHovering, style: overrideBorderStyle)
                } else {
                    LuminareBorder(isHovering: isHovering, style: .default)
                }
            }
            .compositingGroup()
            .shadow(
                color: .black.opacity(colorScheme == .light ? 0.1 : 0),
                radius: 1,
                y: 1
            )
    }
}
