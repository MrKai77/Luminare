//
//  LuminareBorderedModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

public struct LuminareBorderedStates: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let normal = Self(rawValue: 1 << 0)
    public static let hovering = Self(rawValue: 1 << 1)

    public static let all: Self = [.normal, .hovering]
    public static let none: Self = []
}

public struct LuminareBorderedStyle<F: ShapeStyle, H: ShapeStyle>: Sendable {
    public let normal: F
    public let hovering: H
    
    public init(normal: F, hovering: H) {
        self.normal = normal
        self.hovering = hovering
    }
    
    public init(cascading: some ShapeStyle) where F == AnyShapeStyle, H == AnyShapeStyle {
        self.init(
            normal: AnyShapeStyle(cascading.opacity(0.7)),
            hovering: AnyShapeStyle(cascading)
        )
    }
    
    public init(whenHovering: H) where F == Color {
        self.init(
            normal: .clear,
            hovering: whenHovering
        )
    }
}

/// A stylized modifier that constructs a bordered appearance.
public struct LuminareBorderedModifier<F, H>: ViewModifier where F: ShapeStyle, H: ShapeStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareBorderedStates) private var luminareBorderedStates
    @Environment(\.luminareCompactButtonCornerRadii) private var cornerRadii

    private let isHovering: Bool
    private let style: LuminareBorderedStyle<F,H>

    public init(
        isHovering: Bool = false,
        style: LuminareBorderedStyle<F,H>
    ) {
        self.isHovering = isHovering
        self.style = style
    }

    public init(
        isHovering: Bool = false
    ) where F == AnyShapeStyle, H == AnyShapeStyle {
        self.init(
            isHovering: isHovering,
            style: .init(cascading: .quaternary)
        )
    }

    public func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerRadii: cornerRadii))
            .background {
                if isHovering, luminareBorderedStates.contains(.hovering) {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .strokeBorder(style.normal)
                } else if luminareBorderedStates.contains(.normal) {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .strokeBorder(style.hovering)
                }
            }
    }
}
