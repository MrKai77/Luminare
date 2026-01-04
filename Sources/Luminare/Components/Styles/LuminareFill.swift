//
//  LuminareFill.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

public struct LuminareFillStates: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let normal: Self = .init(rawValue: 1 << 0)
    public static let hovering: Self = .init(rawValue: 1 << 1)
    public static let pressed: Self = .init(rawValue: 1 << 2)

    public static let all: Self = [.normal, .hovering, .pressed]
    public static let none: Self = []
}

public struct LuminareFillStyle<F: ShapeStyle, H: ShapeStyle, P: ShapeStyle>: Sendable {
    public let normal: F
    public let hovering: H
    public let pressed: P

    public init(
        normal: F,
        hovering: H = Color.clear,
        pressed: P = Color.clear
    ) {
        self.normal = normal
        self.hovering = hovering
        self.pressed = pressed
    }

    public static var `default`: LuminareFillStyle<HierarchicalShapeStyle, HierarchicalShapeStyle, HierarchicalShapeStyle> {
        .init(
            normal: .quinary,
            hovering: .quaternary,
            pressed: .tertiary
        )
    }
}

struct LuminareFill<F, H, P>: View where F: ShapeStyle, H: ShapeStyle, P: ShapeStyle {
    @Environment(\.luminareFilledStates) private var luminareFilledStates

    private let isHovering: Bool
    private let isPressed: Bool
    private let cornerRadii: RectangleCornerRadii
    private let style: LuminareFillStyle<F, H, P>

    init(
        isHovering: Bool,
        isPressed: Bool,
        cornerRadii: RectangleCornerRadii,
        style: LuminareFillStyle<F, H, P>
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.cornerRadii = cornerRadii
        self.style = style
    }

    var body: some View {
        if luminareFilledStates.contains(.pressed), isPressed {
            UnevenRoundedRectangle(cornerRadii: cornerRadii)
                .foregroundStyle(style.pressed)
        } else if luminareFilledStates.contains(.hovering), isHovering {
            UnevenRoundedRectangle(cornerRadii: cornerRadii)
                .foregroundStyle(style.hovering)
        } else if luminareFilledStates.contains(.normal) {
            UnevenRoundedRectangle(cornerRadii: cornerRadii)
                .foregroundStyle(style.normal)
        }
    }
}
