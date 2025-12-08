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
    @Environment(\.luminareIsInsideSection) private var isInsideSection
    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded
    @State private var disableInnerPadding: Bool? = nil

    private let isPressed: Bool
    private let isHovering: Bool
    private let overrideFillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>?
    private let overrideBorderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle>?

    public init(
        isPressed: Bool = false,
        isHovering: Bool = false,
        overrideFillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
        overrideBorderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle>? = nil
    ) {
        self.isPressed = isPressed
        self.isHovering = isHovering
        self.overrideFillStyle = overrideFillStyle
        self.overrideBorderStyle = overrideBorderStyle
    }

    private var radii: RectangleCornerRadii {
        if isInsideSection {
            let disableInnerPadding = disableInnerPadding == true
            let cornerRadii = disableInnerPadding ? cornerRadii : cornerRadii.inset(by: 4)

            return RectangleCornerRadii(
                topLeading: topLeadingRounded ? cornerRadii.topLeading : 2,
                bottomLeading: bottomLeadingRounded ? cornerRadii.bottomLeading : 2,
                bottomTrailing: bottomTrailingRounded ? cornerRadii.bottomTrailing : 2,
                topTrailing: topTrailingRounded ? cornerRadii.topTrailing : 2
            )
        } else {
            return cornerRadii
        }
    }

    public func body(content: Content) -> some View {
        content
            .compositingGroup()
            .opacity(isEnabled ? 1 : 0.5)
            .luminareCornerRadii(radii)
            .background {
                if let overrideFillStyle {
                    LuminareFill(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        cornerRadii: radii,
                        style: overrideFillStyle
                    )
                } else {
                    LuminareFill(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        cornerRadii: radii,
                        style: .init(
                            normal: colorScheme == .light ? AnyShapeStyle(.white.opacity(0.7)) : AnyShapeStyle(.quinary),
                            hovering: colorScheme == .light ? .quinary : .quaternary,
                            pressed: colorScheme == .light ? AnyShapeStyle(.quaternary) : AnyShapeStyle(.tertiary.opacity(0.6))
                        )
                    )
                }

                if let overrideBorderStyle {
                    LuminareBorder(
                        isHovering: isHovering,
                        cornerRadii: radii,
                        style: overrideBorderStyle
                    )
                } else {
                    LuminareBorder(
                        isHovering: isHovering,
                        cornerRadii: radii,
                        style: .default
                    )
                }
            }
            .compositingGroup()
            .shadow(
                color: .black.opacity(colorScheme == .light ? 0.1 : 0),
                radius: 1,
                y: 1
            )
            .readPreference(LuminareSectionStackDisableInnerPaddingKey.self, to: $disableInnerPadding)
    }
}
