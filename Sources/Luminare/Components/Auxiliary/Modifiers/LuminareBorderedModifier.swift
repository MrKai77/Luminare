//
//  LuminareBorderedModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized modifier that constructs a bordered appearance.
public struct LuminareBorderedModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareIsBordered) private var isBordered
    @Environment(\.luminareHasBackground) private var hasBackground
    @Environment(\.luminareCompactButtonCornerRadii) private var cornerRadii

    private let isHovering: Bool
    private let fill: AnyShapeStyle, hovering: AnyShapeStyle

    public init(
        isHovering: Bool = false,
        fill: some ShapeStyle, hovering: some ShapeStyle
    ) {
        self.isHovering = isHovering
        self.fill = .init(fill)
        self.hovering = .init(hovering)
    }

    public init(
        isHovering: Bool = false,
        cascading: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering,
            fill: cascading.opacity(0.7),
            hovering: cascading
        )
    }

    public init(
        isHovering: Bool = false,
        hovering: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering,
            fill: .clear, hovering: hovering
        )
    }

    public init(
        isHovering: Bool = false
    ) {
        self.init(
            isHovering: isHovering,
            cascading: .quaternary
        )
    }

    public func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerRadii: cornerRadii))
            .background {
                if isHovering, hasBackground {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .strokeBorder(fill)
                } else if isBordered {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .strokeBorder(hovering)
                }
            }
    }
}
