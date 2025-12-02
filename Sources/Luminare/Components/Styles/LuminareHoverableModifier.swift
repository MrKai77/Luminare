//
//  LuminareHoverableModifier.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized modifier that constructs a bordered appearance while hovering.
///
/// Combines both of `LuminareFilledModifier` and `LuminareBorderedModifier`.
public struct LuminareHoverableModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareIsInsideSection) private var isInsideSection
    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded
    @State private var disableInnerPadding: Bool? = nil

    private let isPressed: Bool
    private let isHovering: Bool

    public init(
        isPressed: Bool = false,
        isHovering: Bool = false
    ) {
        self.isPressed = isPressed
        self.isHovering = isHovering
    }
    
    private var radii: RectangleCornerRadii {
        if isInsideSection {
            let disableInnerPadding = disableInnerPadding == true
            let cornerRadii = disableInnerPadding ? cornerRadii : cornerRadii.inset(by: 4)
            let defaultCornerRadius: CGFloat = 2
            
            return RectangleCornerRadii(
                topLeading: topLeadingRounded ? cornerRadii.topLeading : defaultCornerRadius,
                bottomLeading: bottomLeadingRounded ? cornerRadii.bottomLeading : defaultCornerRadius,
                bottomTrailing: bottomTrailingRounded ? cornerRadii.bottomTrailing : defaultCornerRadius,
                topTrailing: topTrailingRounded ? cornerRadii.topTrailing : defaultCornerRadius
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
                LuminareFill(
                    isHovering: isHovering,
                    isPressed: isPressed,
                    cornerRadii: radii,
                    style: .default
                )

                LuminareBorder(
                    isHovering: isHovering,
                    cornerRadii: radii,
                    style: .default
                )
            }
            .readPreference(LuminareSectionStackDisableInnerPaddingKey.self, to: $disableInnerPadding)
    }
}
