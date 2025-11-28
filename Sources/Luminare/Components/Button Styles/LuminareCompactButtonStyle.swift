//
//  LuminareCompactButtonStyle.swift
//  Luminare
//
//  Created by KrLite on 2025/4/12.
//

import SwiftUI

/// A stylized button style with a border.
///
/// Can be configured to disable padding when `extraCompact` is set to `true`.
///
/// ![LuminareCompactButtonStyle](LuminareCompactButtonStyle)
public struct LuminareCompactButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareCompactButtonCornerRadii) private var cornerRadii

    @State private var isHovering: Bool

    public init() {
        self.isHovering = false
    }

    #if DEBUG
        init(
            isHovering: Bool = false
        ) {
            self.isHovering = isHovering
        }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .modifier(LuminareAspectRatioModifier())
            .opacity(isEnabled ? 1 : 0.5)
            .modifier(
                LuminarePlateauModifier(
                    isPressed: configuration.isPressed,
                    isHovering: isHovering
                )
            )
            .onHover { isHovering in
                self.isHovering = isHovering
            }
            .animation(animationFast, value: isHovering)
            .luminareCornerRadii(cornerRadii)
    }
}
