//
//  LuminareBorder.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

public struct LuminareBorderStates: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let normal: Self = .init(rawValue: 1 << 0)
    public static let hovering: Self = .init(rawValue: 1 << 1)

    public static let all: Self = [.normal, .hovering]
    public static let none: Self = []
}

public struct LuminareBorderStyle<F: ShapeStyle, H: ShapeStyle>: Sendable {
    public let normal: F
    public let hovering: H

    public init(
        normal: F,
        hovering: H = Color.clear
    ) {
        self.normal = normal
        self.hovering = hovering
    }

    public static var `default`: LuminareBorderStyle<HierarchicalShapeStyle, HierarchicalShapeStyle> {
        .init(
            normal: .quaternary,
            hovering: .quaternary
        )
    }
}

struct LuminareBorder<F, H>: View where F: ShapeStyle, H: ShapeStyle {
    @Environment(\.luminareBorderedStates) private var luminareBorderedStates

    private let isHovering: Bool
    private let cornerRadii: RectangleCornerRadii
    private let style: LuminareBorderStyle<F, H>

    init(
        isHovering: Bool,
        cornerRadii: RectangleCornerRadii,
        style: LuminareBorderStyle<F, H>
    ) {
        self.isHovering = isHovering
        self.cornerRadii = cornerRadii
        self.style = style
    }

    var body: some View {
        if isHovering, luminareBorderedStates.contains(.hovering) {
            UnevenRoundedRectangle(cornerRadii: cornerRadii)
                .strokeBorder(style.hovering)
        } else if luminareBorderedStates.contains(.normal) {
            UnevenRoundedRectangle(cornerRadii: cornerRadii)
                .strokeBorder(style.normal)
        }
    }
}
