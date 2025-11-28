//
//  LuminarePlateauModifier.swift
//  Luminare
//
//  Created by Kai Azim on 2025-11-28.
//

import SwiftUI

public struct LuminarePlateauModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.luminareCornerRadii) private var cornerRadii

    private let isPressed: Bool
    private let isHovering: Bool

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
            .background {
                ZStack {
                    LuminareFill(
                        isHovering: isHovering,
                        isPressed: isPressed,
                        style: .init(
                            normal: colorScheme == .light ? AnyShapeStyle(.white.opacity(0.7)) : AnyShapeStyle(.quinary),
                            hovering: colorScheme == .light ? .quinary : .quaternary,
                            pressed: colorScheme == .light ? .quaternary : .tertiary
                        )
                    )
                    
                    LuminareBorder(
                        isHovering: isHovering,
                        style: .init(
                            normal: .quaternary,
                            hovering: .quaternary
                        )
                    )
                }
                .clipShape(.rect(cornerRadii: cornerRadii))
            }
            .shadow(
                color: .black.opacity(colorScheme == .light ? 0.1 : 0),
                radius: 2,
                y: 1
            )
    }
}
