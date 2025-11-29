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

    private let isPressed: Bool
    private let isHovering: Bool

    public init(
        isPressed: Bool = false,
        isHovering: Bool = false
    ) {
        self.isPressed = isPressed
        self.isHovering = isHovering
    }

    public func body(content: Content) -> some View {
        content
            .compositingGroup()
            .opacity(isEnabled ? 1 : 0.5)
            .background {
                ZStack {
                    LuminareFill(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        style: .init(
                            normal: colorScheme == .light ? AnyShapeStyle(.white.opacity(0.7)) : AnyShapeStyle(.quinary),
                            hovering: colorScheme == .light ? .quinary : .quaternary,
                            pressed: colorScheme == .light ? AnyShapeStyle(.quaternary) : AnyShapeStyle(.tertiary.opacity(0.6))
                        )
                    )

                    LuminareBorder(
                        isHovering: isHovering,
                        style: .default
                    )
                }
                .clipShape(.rect(cornerRadii: cornerRadii))
            }
            .shadow(
                color: .black.opacity(colorScheme == .light ? 0.1 : 0),
                radius: 1,
                y: 1
            )
    }
}
