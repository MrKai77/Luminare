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
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareCornerRadii) private var cornerRadii

    private let isPressed: Bool
    @State private var isHovering: Bool

    public init(
        isPressed: Bool = false
    ) {
        self.init(
            isPressed: isPressed,
            isHovering: false
        )
    }

    // Note: not public!
    init(
        isPressed: Bool = false,
        isHovering: Bool = false
    ) {
        self.isPressed = isPressed
        self.isHovering = isHovering
    }

    public func body(content: Content) -> some View {
        content
            .compositingGroup()
            .padding(.horizontal, horizontalPadding)
            .modifier(LuminareAspectRatioModifier())
            .opacity(isEnabled ? 1 : 0.5)
            .background {
                ZStack {
                    LuminareFill(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        style: .default
                    )

                    LuminareBorder(
                        isHovering: isHovering,
                        style: .default
                    )
                }
                .clipShape(.rect(cornerRadii: cornerRadii))
            }
            .onHover { isHovering in
                withAnimation(animationFast) {
                    self.isHovering = isHovering
                }
            }
    }
}
