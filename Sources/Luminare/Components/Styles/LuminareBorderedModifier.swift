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

    public static let normal: Self = .init(rawValue: 1 << 0)
    public static let hovering: Self = .init(rawValue: 1 << 1)

    public static let all: Self = [.normal, .hovering]
    public static let none: Self = []
}

public struct LuminareBorderedStyle<F: ShapeStyle, H: ShapeStyle>: Sendable {
    public let normal: F
    public let hovering: H

    public init(
        normal: F,
        hovering: H = Color.clear
    ) {
        self.normal = normal
        self.hovering = hovering
    }

    public static var `default`: LuminareBorderedStyle<HierarchicalShapeStyle, HierarchicalShapeStyle> {
        .init(
            normal: .quaternary,
            hovering: .quaternary
        )
    }
}

/// A stylized modifier that constructs a bordered appearance.
public struct LuminareBorderedModifier<F, H>: ViewModifier where F: ShapeStyle, H: ShapeStyle {
    private let isHovering: Bool
    private let style: LuminareBorderedStyle<F, H>

    public init(
        isHovering: Bool = false,
        style: LuminareBorderedStyle<F, H> = .default
    ) {
        self.isHovering = isHovering
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .background {
                LuminareBorder(
                    isHovering: isHovering,
                    style: style
                )
            }
    }
}

public struct LuminareBorder<F, H>: View where F: ShapeStyle, H: ShapeStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareBorderedStates) private var luminareBorderedStates

    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareIsInsideSection) private var isInsideSection
    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded
    @State private var disableInnerPadding: Bool? = nil

    private let isHovering: Bool
    private let style: LuminareBorderedStyle<F, H>

    public init(
        isHovering: Bool = false,
        style: LuminareBorderedStyle<F, H> = .default
    ) {
        self.isHovering = isHovering
        self.style = style
    }

    public var body: some View {
        Group {
            let shape = getShape()

            if isEnabled {
                if isHovering, luminareBorderedStates.contains(.hovering) {
                    shape
                        .strokeBorder(style.hovering)
                } else if luminareBorderedStates.contains(.normal) {
                    shape
                        .strokeBorder(style.normal)
                }
            } else {
                shape
                    .strokeBorder(style.normal)
                    .opacity(isEnabled ? 1 : 0.5)
            }
        }
        .readPreference(LuminareSectionStackDisableInnerPaddingKey.self, to: $disableInnerPadding)
    }
    
    func getShape() -> UnevenRoundedRectangle {
        if isInsideSection {
            let disableInnerPadding = disableInnerPadding == true
            let cornerRadii = disableInnerPadding ? cornerRadii : cornerRadii.inset(by: 4)
            let defaultCornerRadius: CGFloat = 4
            return UnevenRoundedRectangle(
                topLeadingRadius: topLeadingRounded ? cornerRadii.topLeading : defaultCornerRadius,
                bottomLeadingRadius: bottomLeadingRounded ? cornerRadii.bottomLeading : defaultCornerRadius,
                bottomTrailingRadius: bottomTrailingRounded ? cornerRadii.bottomTrailing : defaultCornerRadius,
                topTrailingRadius: topTrailingRounded ? cornerRadii.topTrailing : defaultCornerRadius,
            )
        } else {
            return UnevenRoundedRectangle(cornerRadii: cornerRadii)
        }
    }
}
