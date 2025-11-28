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
}


/// A stylized modifier that constructs a bordered appearance.
public struct LuminareBorderedModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareBorderedStates) private var luminareBorderedStates
    @Environment(\.luminareCompactButtonCornerRadii) private var cornerRadii

    private let isHovering: Bool
    private let fill: AnyShapeStyle, hovering: AnyShapeStyle

    public init(
        isHovering: Bool = false,
        fill: some ShapeStyle,
        hovering: some ShapeStyle
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
                if isHovering, luminareBorderedStates.contains(.hovering) {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .strokeBorder(fill)
                } else if luminareBorderedStates.contains(.normal) {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .strokeBorder(hovering)
                }
            }
    }
}
