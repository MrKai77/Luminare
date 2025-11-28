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

    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .compositingGroup()
            .background {
                ZStack {
                    LuminareFill(
                        style: .init(
                            normal: colorScheme == .light ? AnyShapeStyle(.white.opacity(0.7)) : AnyShapeStyle(.quinary)
                        )
                    )
                    
                    LuminareBorder(
                        style: .init(
                            normal: .quaternary
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
