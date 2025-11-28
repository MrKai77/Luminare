//
//  LuminareFilledModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

public struct LuminareFilledStates: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let normal = Self(rawValue: 1 << 0)
    public static let hovering = Self(rawValue: 1 << 1)
    public static let pressed = Self(rawValue: 1 << 2)

    public static let all: Self = [.normal, .hovering, .pressed]
    public static let none: Self = []
}

public struct LuminareFilledStyle<F: ShapeStyle, H: ShapeStyle, P: ShapeStyle>: Sendable {
    public let normal: F
    public let hovering: H
    public let pressed: P

    public init(normal: F, hovering: H, pressed: P) {
        self.normal = normal
        self.hovering = hovering
        self.pressed = pressed
    }

    public static var `default`: LuminareFilledStyle<HierarchicalShapeStyle, HierarchicalShapeStyle, HierarchicalShapeStyle> {
        .init(
            normal: .quinary,
            hovering: .quaternary,
            pressed: .tertiary
        )
    }
}

public struct LuminareFilledModifier<F, H, P>: ViewModifier where F: ShapeStyle, H: ShapeStyle, P: ShapeStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareFilledStates) private var luminareFilledStates
    @Environment(\.luminareButtonMaterial) private var material

    private let isHovering: Bool, isPressed: Bool
    private let style: LuminareFilledStyle<F, H, P>

    public init(
        isHovering: Bool,
        isPressed: Bool,
        style: LuminareFilledStyle<F, H, P> = .default
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .background(with: material) {
                Group {
                    if isEnabled {
                        if luminareFilledStates.contains(.pressed), isPressed {
                            Rectangle()
                                .foregroundStyle(style.pressed)
                        } else if luminareFilledStates.contains(.hovering), isHovering {
                            Rectangle()
                                .foregroundStyle(style.hovering)
                        } else if luminareFilledStates.contains(.normal) {
                            Rectangle()
                                .foregroundStyle(style.normal)
                        }
                    } else {
                        if luminareFilledStates.contains(.normal) {
                            Rectangle()
                                .foregroundStyle(style.normal)
                        }
                    }
                }
                .opacity(isEnabled ? 1 : 0.5)
            }
    }
}
