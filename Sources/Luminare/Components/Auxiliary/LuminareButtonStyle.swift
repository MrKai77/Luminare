//
//  LuminareButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

// MARK: - Button Style

public struct LuminareButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast

    private let innerCornerRadius: CGFloat, elementMinHeight: CGFloat

    @State private var isHovering: Bool

    public init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.isHovering = false
    }

#if DEBUG
    init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34,
        isHovering: Bool = false
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.isHovering = isHovering
    }
#endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    styles: (
                        .quaternary, .quaternary.opacity(0.7), .quinary
                    )
                )
            }
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Button Style (Destructive)

public struct LuminareDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast

    private let innerCornerRadius: CGFloat, elementMinHeight: CGFloat

    @State private var isHovering: Bool

    public init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.isHovering = false
    }
    
#if DEBUG
    init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34,
        isHovering: Bool = false
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.isHovering = isHovering
    }
#endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    layered: .red
                )
            }
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Button Style (Prominent)

public struct LuminareProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast

    private let innerCornerRadius: CGFloat, elementMinHeight: CGFloat

    @State private var isHovering: Bool

    public init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.isHovering = false
    }

#if DEBUG
    init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34,
        isHovering: Bool = false
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.isHovering = isHovering
    }
#endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    layered: .tint
                )
            }
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
    }

    @ViewBuilder static func tintedBackgroundForState<F: ShapeStyle>(
        isPressed: Bool, isEnabled: Bool, isHovering: Bool,
        layered: F
    ) -> some View {
        tintedBackgroundForState(isPressed: isPressed, isEnabled: isEnabled, isHovering: isHovering, styles: (
            layered.opacity(0.4),
            layered.opacity(0.25),
            layered.opacity(0.15)
        ))
    }

    @ViewBuilder static func tintedBackgroundForState<F1: ShapeStyle, F2: ShapeStyle, F3: ShapeStyle>(
        isPressed: Bool, isEnabled: Bool, isHovering: Bool,
        styles: (F1, F2, F3)
    ) -> some View {
        Group {
            if isPressed, isEnabled {
                Rectangle().foregroundStyle(styles.0)
            } else if isHovering, isEnabled {
                Rectangle().foregroundStyle(styles.1)
            } else {
                Rectangle().foregroundStyle(styles.2)
            }
        }
    }
}

// MARK: - Button Style (Cosmetic)

public struct LuminareCosmeticButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.luminareAnimationFast) private var animationFast

    private let innerCornerRadius: CGFloat, elementMinHeight: CGFloat
    @ViewBuilder private let icon: () -> Image

    @State private var isHovering: Bool

    public init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34,
        @ViewBuilder icon: @escaping () -> Image
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.icon = icon
        self.isHovering = false
    }

#if DEBUG
    init(
        innerCornerRadius: CGFloat = 2,
        elementMinHeight: CGFloat = 34,
        isHovering: Bool = false,
        @ViewBuilder icon: @escaping () -> Image
    ) {
        self.innerCornerRadius = innerCornerRadius
        self.elementMinHeight = elementMinHeight
        self.icon = icon
        self.isHovering = isHovering
    }
#endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    styles: (
                        .quaternary, .quaternary.opacity(0.7), .clear
                    )
                )
            }
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .opacity(isEnabled ? 1 : 0.5)
            .overlay {
                HStack {
                    Spacer()

                    icon()
                        .opacity(isHovering ? 1 : 0)
                }
                .padding(24)
                .allowsHitTesting(false)
            }
    }
}

// MARK: - Button Style (Compact)

public struct LuminareCompactButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.luminareAnimationFast) private var animationFast

    private let elementMinHeight: CGFloat, elementExtraMinHeight: CGFloat
    private let extraCompact: Bool
    private let cornerRadius: CGFloat

    @State var isHovering: Bool

    public init(
        elementMinHeight: CGFloat = 34,
        elementExtraMinHeight: CGFloat = 25,
        extraCompact: Bool = false,
        cornerRadius: CGFloat = 8
    ) {
        self.elementMinHeight = elementMinHeight
        self.elementExtraMinHeight = elementExtraMinHeight
        self.extraCompact = extraCompact
        self.cornerRadius = cornerRadius
        self.isHovering = false
    }

#if DEBUG
    init(
        elementMinHeight: CGFloat = 34,
        elementExtraMinHeight: CGFloat = 25,
        extraCompact: Bool = false,
        cornerRadius: CGFloat = 8,
        isHovering: Bool = false
    ) {
        self.elementMinHeight = elementMinHeight
        self.elementExtraMinHeight = elementExtraMinHeight
        self.extraCompact = extraCompact
        self.cornerRadius = cornerRadius
        self.isHovering = isHovering
    }
#endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, extraCompact ? 0 : 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    styles: (
                        .quaternary, .quaternary.opacity(0.7), .quinary
                    )
                )
            }
            .background(border())
            .fixedSize(horizontal: extraCompact, vertical: extraCompact)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: extraCompact ? elementExtraMinHeight : elementMinHeight)
            .opacity(isEnabled ? 1 : 0.5)
    }

    @ViewBuilder private func border() -> some View {
        Group {
            if isHovering {
                RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(.quaternary, lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(.quaternary.opacity(0.7), lineWidth: 1)
            }
        }
    }
}

// MARK: - Bordered

public struct LuminareBordered: ViewModifier {
    private let isHighlighted: Bool
    private let cornerRadius: CGFloat

    public init(
        highlighted: Bool = false,
        cornerRadius: CGFloat = 8
    ) {
        self.isHighlighted = highlighted
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background {
                if isHighlighted {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                } else {
                    Rectangle().foregroundStyle(.quinary)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}
