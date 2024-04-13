//
//  LuminareButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    @State var isHovering: Bool = false

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if configuration.isPressed && isEnabled {
                    Rectangle().foregroundStyle(.quaternary)
                } else if isHovering && isEnabled {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                } else {
                    Rectangle().foregroundStyle(.quinary)
                }
            }
            .onHover { hover in
                self.isHovering = hover
            }
            .animation(.easeOut(duration: 0.1), value: [self.isHovering, configuration.isPressed])
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
    }
}

public struct LuminareDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    @State var isHovering: Bool = false

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if configuration.isPressed && isEnabled {
                    Rectangle().foregroundStyle(.red.opacity(0.4))
                } else if isHovering && isEnabled {
                    Rectangle().foregroundStyle(.red.opacity(0.25))
                } else {
                    Rectangle().foregroundStyle(.red.opacity(0.15))
                }
            }
            .onHover { hover in
                self.isHovering = hover
            }
            .animation(.easeOut(duration: 0.1), value: [self.isHovering, configuration.isPressed])
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
    }
}
