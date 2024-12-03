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
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadius) private var buttonCornerRadius

    @State private var isHovering: Bool = false

    public init() {}

    #if DEBUG
        init(
            isHovering: Bool = false
        ) {
            self.isHovering = isHovering
        }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: minHeight)
            .opacity(isEnabled ? 1 : 0.5)
            .background(with: material) {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    styles: (
                        .quaternary, .quaternary.opacity(0.7), .quinary
                    )
                )
                .opacity(isEnabled ? 1 : 0.5)
            }
            .clipShape(.rect(cornerRadius: buttonCornerRadius))
    }
}

// MARK: - Button Style (Destructive)

/// A stylized button style tinted in red, typically used for indicating a destructive action.
///
/// ![LuminareDestructiveButtonStyle](LuminareDestructiveButtonStyle)
public struct LuminareDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadius) private var buttonCornerRadius

    @State private var isHovering: Bool = false

    public init() {}

    #if DEBUG
        init(
            isHovering: Bool = false
        ) {
            self.isHovering = isHovering
        }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: minHeight)
            .opacity(isEnabled ? 1 : 0.5)
            .background(with: material) {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    layered: .red
                )
                .opacity(isEnabled ? 1 : 0.5)
            }
            .clipShape(.rect(cornerRadius: buttonCornerRadius))
    }
}

// MARK: - Button Style (Prominent)

/// A stylized button style that can be tinted.
///
/// To tint the button, use the `.tint()` or `.overrideTint()` modifier.
///
/// ![LuminareProminentButtonStyle](LuminareProminentButtonStyle)
public struct LuminareProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadius) private var buttonCornerRadius

    @State private var isHovering: Bool = false

    public init() {}

    #if DEBUG
        init(
            isHovering: Bool = false
        ) {
            self.isHovering = isHovering
        }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: minHeight)
            .opacity(isEnabled ? 1 : 0.5)
            .background(with: material) {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    layered: .tint
                )
                .opacity(isEnabled ? 1 : 0.5)
            }
            .clipShape(.rect(cornerRadius: buttonCornerRadius))
    }

    @ViewBuilder static func tintedBackgroundForState(
        isPressed: Bool, isEnabled: Bool, isHovering: Bool,
        layered: some ShapeStyle
    ) -> some View {
        tintedBackgroundForState(isPressed: isPressed, isEnabled: isEnabled, isHovering: isHovering, styles: (
            layered.opacity(0.4),
            layered.opacity(0.25),
            layered.opacity(0.15)
        ))
    }

    @ViewBuilder static func tintedBackgroundForState(
        isPressed: Bool, isEnabled: Bool, isHovering: Bool,
        styles: (some ShapeStyle, some ShapeStyle, some ShapeStyle)
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
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadius) private var buttonCornerRadius

    @ViewBuilder private let icon: () -> Image

    @State private var isHovering: Bool = false

    /// Initializes a ``LuminareCosmeticButtonStyle``.
    ///
    /// - Parameters:
    ///   - icon: the trailing aligned `Image` to display while hovering.
    public init(
        @ViewBuilder icon: @escaping () -> Image
    ) {
        self.icon = icon
    }

    #if DEBUG
        init(
            isHovering: Bool = false,
            @ViewBuilder icon: @escaping () -> Image
        ) {
            self.icon = icon
            self.isHovering = isHovering
        }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: minHeight)
            .opacity(isEnabled ? 1 : 0.5)
            .background(with: material) {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    styles: (
                        .quaternary, .quaternary.opacity(0.7), .clear
                    )
                )
                .opacity(isEnabled ? 1 : 0.5)
            }
            .overlay {
                HStack {
                    Spacer()

                    icon()
                        .opacity(isHovering ? 1 : 0)
                }
                .padding(24)
                .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadius: buttonCornerRadius))
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
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadius) private var buttonCornerRadius

    private let extraCompact: Bool

    @State private var isHovering: Bool = false

    /// Initializes a ``LuminareButtonStyle``.
    ///
    /// - Parameters:
    ///   - extraCompact: whether to eliminate the padding around the content.
    public init(
        extraCompact: Bool = false
    ) {
        self.extraCompact = extraCompact
    }

    #if DEBUG
        init(
            extraCompact: Bool = false,
            isHovering: Bool = false
        ) {
            self.extraCompact = extraCompact
            self.isHovering = isHovering
        }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, extraCompact ? 0 : 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(border())
            .fixedSize(horizontal: extraCompact, vertical: extraCompact)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .frame(minHeight: minHeight)
            .opacity(isEnabled ? 1 : 0.5)
            .background(with: material) {
                LuminareProminentButtonStyle.tintedBackgroundForState(
                    isPressed: configuration.isPressed, isEnabled: isEnabled, isHovering: isHovering,
                    styles: (
                        .quaternary, .quaternary.opacity(0.7), .quinary
                    )
                )
                .opacity(isEnabled ? 1 : 0.5)
            }
            .clipShape(.rect(cornerRadius: buttonCornerRadius))
    }

    @ViewBuilder private func border() -> some View {
        Group {
            if isHovering {
                RoundedRectangle(cornerRadius: buttonCornerRadius).strokeBorder(.quaternary)
            } else {
                RoundedRectangle(cornerRadius: buttonCornerRadius).strokeBorder(.quaternary.opacity(0.7))
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
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadius) private var buttonCornerRadius

    private let isHighlighted: Bool

    /// Initializes a ``LuminareBordered``.
    ///
    /// - Parameters:
    ///   - isHighlighted: whether to display a highlighted overlay.
    ///   - buttonCornerRadius: the corner radius of the button.
    public init(
        isHighlighted: Bool = false
    ) {
        self.isHighlighted = isHighlighted
    }

    public func body(content: Content) -> some View {
        content
            .background(with: material) {
                if isHighlighted {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                } else {
                    Rectangle().foregroundStyle(.quinary)
                }
            }
            .clipShape(.rect(cornerRadius: buttonCornerRadius))
            .background {
                RoundedRectangle(cornerRadius: buttonCornerRadius)
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
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareIsBordered) private var isBordered
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareCompactButtonCornerRadius) private var buttonCornerRadius

    @State private var isHovering: Bool = false

    public init() {}

    #if DEBUG
        init(
            isHovering: Bool = false
        ) {
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
            .frame(minHeight: minHeight)
            .padding(.horizontal, horizontalPadding)
            .background(with: material) {
                if isHovering {
                    Rectangle()
                        .foregroundStyle(.quinary)
                } else {
                    Rectangle()
                        .foregroundStyle(.clear)
                }
            }
            .clipShape(.rect(cornerRadius: buttonCornerRadius))
            .background {
                if isHovering {
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .strokeBorder(.quaternary)
                } else if isBordered {
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .strokeBorder(.quaternary.opacity(0.7))
                }
            }
    }
}
