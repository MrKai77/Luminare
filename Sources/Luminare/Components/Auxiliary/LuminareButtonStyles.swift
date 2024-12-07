//
//  LuminareButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

struct AspectRatioModifier: ViewModifier {
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonAspectRatio) private var aspectRatio
    @Environment(\.luminareButtonIsVerticallyCompact) private var isVerticallyCompact
    
    @ViewBuilder func body(content: Content) -> some View {
        Group {
            if isConstrained {
                content
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: minHeight, maxHeight: isVerticallyCompact ? nil : .infinity)
                    .aspectRatio(aspectRatio.aspectRatio, contentMode: aspectRatio.contentMode)
            } else {
                content
                    .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: .infinity)
            }
        }
        .fixedSize(horizontal: aspectRatio.contentMode == .fit, vertical: isVerticallyCompact)
    }
    
    private var isConstrained: Bool {
        aspectRatio.contentMode == .fit || isVerticallyCompact
    }
}

// MARK: - Button Styles

/// A stylized button style.
///
/// ![LuminareButtonStyle](LuminareButtonStyle)
public struct LuminareButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonCornerRadius) private var cornerRadius
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

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
        
            .modifier(LuminareFilled(
                isHovering: isHovering, isPressed: configuration.isPressed,
                fill: .quinary, hovering: .quaternary.opacity(0.7), pressed: .quaternary
            ))
            .clipShape(.rect(cornerRadius: cornerRadius))
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
    @Environment(\.luminareButtonCornerRadius) private var cornerRadius
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

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
        
            .modifier(LuminareFilled(
                isHovering: isHovering, isPressed: configuration.isPressed,
                cascading: .red
            ))
            .clipShape(.rect(cornerRadius: cornerRadius))
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
    @Environment(\.luminareButtonCornerRadius) private var cornerRadius
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

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
        
            .modifier(LuminareFilled(
                isHovering: isHovering, isPressed: configuration.isPressed,
                cascading: .tint
            ))
            .clipShape(.rect(cornerRadius: cornerRadius))
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
    @Environment(\.luminareButtonCornerRadius) private var cornerRadius
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

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
        
            .modifier(LuminareFilled(
                isHovering: isHovering, isPressed: configuration.isPressed
            ))
            .overlay {
                HStack {
                    Spacer()

                    icon()
                        .opacity(isHovering ? 1 : 0)
                }
                .padding(24)
                .allowsHitTesting(false)
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
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
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareCompactButtonCornerRadius) private var cornerRadius
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

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
            .padding(.horizontal, horizontalPadding)
            .modifier(AspectRatioModifier())
            .opacity(isEnabled ? 1 : 0.5)
        
            .modifier(LuminareFilled(
                isHovering: isHovering, isPressed: configuration.isPressed,
                fill: .quinary, hovering: .quaternary.opacity(0.7), pressed: .quaternary
            ))
            .modifier(LuminareBordered(isHovering: isHovering))
        
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
    }
}

// MARK: - Filled

public struct LuminareFilled: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover
    
    private let isHovering: Bool, isPressed: Bool
    private let fill: AnyShapeStyle, hovering: AnyShapeStyle, pressed: AnyShapeStyle
    
    public init(
        isHovering: Bool = false, isPressed: Bool = false,
        fill: some ShapeStyle, hovering: some ShapeStyle, pressed: some ShapeStyle
    ) {
        self.isHovering = isHovering
        self.isPressed = isPressed
        self.fill = .init(fill)
        self.hovering = .init(hovering)
        self.pressed = .init(pressed)
    }
    
    public init(
        isHovering: Bool = false, isPressed: Bool = false,
        cascading: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering, isPressed: isPressed,
            fill: cascading.opacity(0.15),
            hovering: cascading.opacity(0.25),
            pressed: cascading.opacity(0.4)
        )
    }
    
    public init(
        isHovering: Bool = false, isPressed: Bool = false,
        pressed: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering, isPressed: isPressed,
            fill: .clear, hovering: pressed, pressed: pressed
        )
    }
    
    public init(
        isHovering: Bool = false, isPressed: Bool = false
    ) {
        self.init(
            isHovering: isHovering, isPressed: isPressed,
            pressed: .quinary
        )
    }
    
    public func body(content: Content) -> some View {
        content
            .background(with: material) {
                Group {
                    if isEnabled {
                        if isPressed {
                            Rectangle()
                                .foregroundStyle(pressed)
                        } else if highlightOnHover, isHovering {
                            Rectangle()
                                .foregroundStyle(hovering)
                        } else {
                            Rectangle()
                                .foregroundStyle(fill)
                        }
                    } else {
                        Rectangle()
                            .foregroundStyle(fill)
                    }
                }
                .opacity(isEnabled ? 1 : 0.5)
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
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareCompactButtonCornerRadius) private var cornerRadius
    @Environment(\.luminareIsBordered) private var isBordered

    private let isHovering: Bool
    private let fill: AnyShapeStyle, hovering: AnyShapeStyle

    public init(
        isHovering: Bool = false,
        fill: some ShapeStyle, hovering: some ShapeStyle
    ) {
        self.isHovering = isHovering
        self.fill = .init(fill)
        self.hovering = .init(hovering)
    }
    
    public init(
        isHovering: Bool = false,
        cascading: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering,
            fill: cascading.opacity(0.7),
            hovering: cascading
        )
    }
    
    public init(
        isHovering: Bool = false,
        hovering: some ShapeStyle
    ) {
        self.init(
            isHovering: isHovering,
            fill: .clear, hovering: hovering
        )
    }
    
    public init(
        isHovering: Bool = false
    ) {
        self.init(
            isHovering: isHovering,
            cascading: .quaternary
        )
    }

    public func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerRadius: cornerRadius))
            .background {
                if isHovering {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(fill)
                } else if isBordered {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(hovering)
                }
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
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareButtonMaterial) private var material
    @Environment(\.luminareCompactButtonCornerRadius) private var cornerRadius
    @Environment(\.luminareIsBordered) private var isBordered
    @Environment(\.luminareButtonHighlightOnHover) private var highlightOnHover

    private let isPressed: Bool
    private let fill: AnyShapeStyle, hovering: AnyShapeStyle, pressed: AnyShapeStyle

    @State private var isHovering: Bool = false

    public init(
        isPressed: Bool = false,
        fill: some ShapeStyle, hovering: some ShapeStyle, pressed: some ShapeStyle
    ) {
        self.isPressed = isPressed
        self.fill = .init(fill)
        self.hovering = .init(hovering)
        self.pressed = .init(pressed)
    }
    
    public init(
        isPressed: Bool = false,
        cascading: some ShapeStyle
    ) {
        self.init(
            isPressed: isPressed,
            fill: cascading.opacity(0.15),
            hovering: cascading.opacity(0.25),
            pressed: cascading.opacity(0.4)
        )
    }
    
    public init(
        isPressed: Bool = false,
        pressed: some ShapeStyle
    ) {
        self.init(
            isPressed: isPressed,
            fill: .clear, hovering: pressed, pressed: pressed
        )
    }
    
    public init(
        isPressed: Bool = false
    ) {
        self.init(
            isPressed: isPressed,
            pressed: .quinary
        )
    }

    #if DEBUG
        init(
            isPressed: Bool = false,
            fill: some ShapeStyle, hovering: some ShapeStyle, pressed: some ShapeStyle,
            isHovering: Bool = false
        ) {
            self.isPressed = isPressed
            self.fill = .init(fill)
            self.hovering = .init(hovering)
            self.pressed = .init(pressed)
            self.isHovering = isHovering
        }
    #endif

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .modifier(AspectRatioModifier())
            .opacity(isEnabled ? 1 : 0.5)
        
            .modifier(LuminareFilled(
                isHovering: isHovering, isPressed: isPressed,
                fill: fill, hovering: hovering, pressed: pressed
            ))
            .modifier(LuminareBordered(isHovering: isHovering))
        
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
    }
}
