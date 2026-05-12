//
//  LuminareSurfaceModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2025-11-28.
//

import SwiftUI

public struct LuminareSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareIsInsideSection) private var isInsideSection
    @Environment(\.luminareSurfaceStyle) private var style
    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded
    @State private var disableInnerPadding: Bool? = nil

    private let isHovering: Bool
    private let isPressed: Bool
    private let respectsDisablement: Bool

    public init(
        isHovering: Bool = false,
        isPressed: Bool = false
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.respectsDisablement = true
    }

    init(
        isHovering: Bool = false,
        isPressed: Bool = false,
        respectsDisablement: Bool
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.respectsDisablement = respectsDisablement
    }

    private var radii: RectangleCornerRadii {
        if isInsideSection {
            let disableInnerPadding = disableInnerPadding == true
            let cornerRadii = disableInnerPadding ? cornerRadii : cornerRadii.inset(by: 4)

            return RectangleCornerRadii(
                topLeading: topLeadingRounded ? cornerRadii.topLeading : 4,
                bottomLeading: bottomLeadingRounded ? cornerRadii.bottomLeading : 4,
                bottomTrailing: bottomTrailingRounded ? cornerRadii.bottomTrailing : 4,
                topTrailing: topTrailingRounded ? cornerRadii.topTrailing : 4
            )
        } else {
            return cornerRadii
        }
    }

    public func body(content: Content) -> some View {
        let fillStyle = colorScheme == .dark ? style.darkFillStyle ?? style.fillStyle : style.fillStyle

        content
            .compositingGroup()
            .luminareCornerRadii(radii)
            .background {
                if let fillStyle {
                    LuminareFill(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        cornerRadii: radii,
                        style: fillStyle
                    )
                }

                if let borderStyle = style.borderStyle {
                    LuminareBorder(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        cornerRadii: radii,
                        style: borderStyle
                    )
                }
            }
            .compositingGroup()
            .shadow(
                color: style.shadowStyle?.color(for: colorScheme) ?? .clear,
                radius: style.shadowStyle?.radius ?? 0,
                x: style.shadowStyle?.x ?? 0,
                y: style.shadowStyle?.y ?? 0
            )
            .opacity(!respectsDisablement || isEnabled ? 1 : 0.5)
            .readPreference(LuminareSectionStackDisableInnerPaddingKey.self, to: $disableInnerPadding)
    }
}
