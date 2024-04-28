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

            .opacity(isEnabled ? 1 : 0.5)
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
                Rectangle().foregroundStyle(.quinary.opacity(0.5)) // Helps visibility
            }
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

            .opacity(isEnabled ? 1 : 0.5)
    }
}

public struct LuminareCompactButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    let elementMinHeight: CGFloat = 34
    let elementExtraMinHeight: CGFloat = 25
    let extraCompact: Bool
    @State var isHovering: Bool = false

    let cornerRadius: CGFloat = 8

    public init(extraCompact: Bool = false) {
        self.extraCompact = extraCompact
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, extraCompact ? 0 : 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if configuration.isPressed {
                    Rectangle().foregroundStyle(.quaternary)
                } else if isHovering {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                } else {
                    Rectangle().foregroundStyle(.quinary)
                }
            }
            .background {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .strokeBorder(.quaternary, lineWidth: 1)
            }
            .fixedSize(
                horizontal: extraCompact,
                vertical: extraCompact
            )
            .clipShape(.rect(cornerRadius: cornerRadius))

            .onHover { hover in
                self.isHovering = hover
            }
            .animation(.easeOut(duration: 0.1), value: [self.isHovering, configuration.isPressed])
            .frame(minHeight: extraCompact ? elementExtraMinHeight : elementMinHeight)

            .opacity(isEnabled ? 1 : 0.5)
    }
}

public struct LuminareBordered: ViewModifier {
    @Binding var highlight: Bool
    let cornerRadius: CGFloat = 8
    
    public init(highlight: Binding<Bool> = .constant(false)) {
        self._highlight = highlight
    }

    public func body(content: Content) -> some View {
        content
            .background {
                if self.highlight {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                } else {
                    Rectangle().foregroundStyle(.quinary)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .background {
                RoundedRectangle(
                    cornerRadius: self.cornerRadius,
                    style: .continuous
                )
                .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}
