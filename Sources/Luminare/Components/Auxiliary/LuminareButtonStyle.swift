//
//  LuminareButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

// MARK: - Button Style

/// A stylized button style.
///
/// ![LuminareButtonStyle](LuminareButtonStyle)
public struct LuminareButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast

    private let innerCornerRadius: CGFloat, elementMinHeight: CGFloat

    @State private var isHovering: Bool

    /// Initializes a ``LuminareButtonStyle``.
    ///
    /// - Parameters:
    ///   - innerCornerRadius: the corner radius of the background.
    ///   - elementMinHeight: the minimum height of the background.
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

/// A stylized button style tinted in red, typically used for indicating a destructive action.
///
/// ![LuminareDestructiveButtonStyle](LuminareDestructiveButtonStyle)
public struct LuminareDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast

    private let innerCornerRadius: CGFloat, elementMinHeight: CGFloat

    @State private var isHovering: Bool

    /// Initializes a ``LuminareDestructiveButtonStyle``.
    ///
    /// - Parameters:
    ///   - innerCornerRadius: the corner radius of the background.
    ///   - elementMinHeight: the minimum height of the background.
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

/// A stylized button style that can be tinted.
///
/// To tint the button, use the `.tint()` modifier.
///
/// ![LuminareProminentButtonStyle](LuminareProminentButtonStyle)
public struct LuminareProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast

    private let innerCornerRadius: CGFloat, elementMinHeight: CGFloat

    @State private var isHovering: Bool

    /// Initializes a ``LuminareProminentButtonStyle``.
    ///
    /// - Parameters:
    ///   - innerCornerRadius: the corner radius of the background.
    ///   - elementMinHeight: the minimum height of the background.
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

/// A stylized button style that accepts an additional image for hovering.
///
/// Typically used for complex layouts with a custom avatar.
/// However, the content is not constrained in any specific format.
///
/// ![LuminareCosmeticButtonStyle](LuminareCosmeticButtonStyle)
public struct LuminareCosmeticButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.luminareAnimationFast) private var animationFast

    private let elementMinHeight: CGFloat
    private let innerCornerRadius: CGFloat
    @ViewBuilder private let icon: () -> Image

    @State private var isHovering: Bool

    /// Initializes a ``LuminareCosmeticButtonStyle``.
    ///
    /// - Parameters:
    ///   - elementMinHeight: the minimum height of the background.
    ///   - innerCornerRadius: the corner radius of the background.
    ///   - icon: the trailing aligned `Image` to display while hovering.
    public init(
        elementMinHeight: CGFloat = 34,
        innerCornerRadius: CGFloat = 2,
        @ViewBuilder icon: @escaping () -> Image
    ) {
        self.elementMinHeight = elementMinHeight
        self.innerCornerRadius = innerCornerRadius
        self.icon = icon
        self.isHovering = false
    }

#if DEBUG
    init(
        elementMinHeight: CGFloat = 34,
        innerCornerRadius: CGFloat = 2,
        isHovering: Bool = false,
        @ViewBuilder icon: @escaping () -> Image
    ) {
        self.elementMinHeight = elementMinHeight
        self.innerCornerRadius = innerCornerRadius
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

/// A stylized button style with a border.
///
/// Can be configured to disable padding when `extraCompact` is set to `true`.
///
/// ![LuminareCompactButtonStyle](LuminareCompactButtonStyle)
public struct LuminareCompactButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.luminareAnimationFast) private var animationFast

    private let extraCompact: Bool
    private let elementMinHeight: CGFloat
    private let innerCornerRadius: CGFloat

    @State var isHovering: Bool

    /// Initializes a ``LuminareButtonStyle``.
    ///
    /// - Parameters:
    ///   - extraCompact: whether to eliminate the padding around the content.
    ///   - elementMinHeight: the minimum height of the background.
    ///   - innerCornerRadius: the corner radius of the background.
    public init(
        extraCompact: Bool = false,
        elementMinHeight: CGFloat = 34,
        innerCornerRadius: CGFloat = 8
    ) {
        self.extraCompact = extraCompact
        self.elementMinHeight = elementMinHeight
        self.innerCornerRadius = innerCornerRadius
        self.isHovering = false
    }

#if DEBUG
    init(
        extraCompact: Bool = false,
        elementMinHeight: CGFloat = 34,
        innerCornerRadius: CGFloat = 8,
        isHovering: Bool = false
    ) {
        self.extraCompact = extraCompact
        self.elementMinHeight = elementMinHeight
        self.innerCornerRadius = innerCornerRadius
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
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: elementMinHeight)
            .opacity(isEnabled ? 1 : 0.5)
    }

    @ViewBuilder private func border() -> some View {
        Group {
            if isHovering {
                RoundedRectangle(cornerRadius: innerCornerRadius).strokeBorder(.quaternary)
            } else {
                RoundedRectangle(cornerRadius: innerCornerRadius).strokeBorder(.quaternary.opacity(0.7))
            }
        }
    }
}

// MARK: - Bordered

/// A stylized modifier that constructs a bordered appearance.
///
/// @Row {
///     @Column(size: 2) {
///         This looks like a ``LuminareCompactButtonStyle``, but is not limited to buttons.
///     }
///
///     @Column {
///         ![LuminareButtonStyle](LuminareBordered)
///     }
/// }
public struct LuminareBordered: ViewModifier {
    private let isHighlighted: Bool
    private let innerCornerRadius: CGFloat

    /// Initializes a ``LuminareBordered``.
    ///
    /// - Parameters:
    ///   - isHighlighted: whether to display a highlighted overlay.
    ///   - innerCornerRadius: the corner radius of the background.
    public init(
        isHighlighted: Bool = false,
        innerCornerRadius: CGFloat = 8
    ) {
        self.isHighlighted = isHighlighted
        self.innerCornerRadius = innerCornerRadius
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
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .background {
                RoundedRectangle(cornerRadius: innerCornerRadius)
                    .strokeBorder(.quaternary)
            }
    }
}

// MARK: - Hoverable

/// A stylized modifier that constructs a bordered appearance while hovering.
///
/// @Row {
///     @Column(size: 2) {
///         While not hovering, the visibility of the border can be configured through `isBordered`.
///     }
///
///     @Column {
///         ![LuminareHoverable](LuminareHoverable)
///     }
/// }
public struct LuminareHoverable: ViewModifier {
    @Environment(\.luminareAnimationFast) private var animationFast

    private let elementMinHeight: CGFloat, horizontalPadding: CGFloat
    private let innerCornerRadius: CGFloat
    private let isBordered: Bool

    @State private var isHovering: Bool

    /// Initializes a ``LuminareHoverable``.
    ///
    /// - Parameters:
    ///   - elementMinHeight: the minimum height of the background.
    ///   - horizontalPadding: the horizontal padding around the content.
    ///   - innerCornerRadius: the corner radius of the background.
    ///   - isBordered: whether to display a border while not hovering.
    public init(
        elementMinHeight: CGFloat = 32, horizontalPadding: CGFloat = 8,
        innerCornerRadius: CGFloat = 8,
        isBordered: Bool = false
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.innerCornerRadius = innerCornerRadius
        self.isBordered = isBordered
        self.isHovering = false
    }

#if DEBUG
    init(
        elementMinHeight: CGFloat = 32, horizontalPadding: CGFloat = 8,
        innerCornerRadius: CGFloat = 8,
        isBordered: Bool = false,
        isHovering: Bool = false
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.innerCornerRadius = innerCornerRadius
        self.isBordered = isBordered
        self.isHovering = isHovering
    }
#endif

    public func body(content: Content) -> some View {
        content
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: elementMinHeight)
            .padding(.horizontal, horizontalPadding)
            .background {
                if isHovering {
                    Rectangle()
                        .foregroundStyle(.quinary)
                } else {
                    Rectangle()
                        .foregroundStyle(.clear)
                }
            }
            .clipShape(.rect(cornerRadius: innerCornerRadius))
            .background {
                if isHovering {
                    RoundedRectangle(cornerRadius: innerCornerRadius)
                        .strokeBorder(.quaternary)
                } else if isBordered {
                    RoundedRectangle(cornerRadius: innerCornerRadius)
                        .strokeBorder(.quaternary.opacity(0.7))
                }
            }
    }
}
