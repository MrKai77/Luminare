//
//  LuminareButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    
    @State private var isHovering: Bool = false

    public init() {}

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

public struct LuminareDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    
    @State var isHovering: Bool = false

    public init() {}

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

public struct LuminareProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    
    @State var isHovering: Bool = false
    
    public init() {}
    
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
    
    @ViewBuilder static func tintedBackgroundForState<
        F: ShapeStyle
    >(isPressed: Bool, isEnabled: Bool, isHovering: Bool, layered: F) -> some View {
        tintedBackgroundForState(isPressed: isPressed, isEnabled: isEnabled, isHovering: isHovering, styles: (
            layered.opacity(0.4),
            layered.opacity(0.25),
            layered.opacity(0.15)
        ))
    }
    
    @ViewBuilder static func tintedBackgroundForState<
        F1: ShapeStyle, F2: ShapeStyle, F3: ShapeStyle
    >(isPressed: Bool, isEnabled: Bool, isHovering: Bool, styles: (F1, F2, F3)) -> some View {
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

public struct LuminareCosmeticButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.luminareAnimationFast) private var animationFast
    
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 34
    
    @State var isHovering: Bool = false
    let icon: Image

    public init(_ icon: Image) {
        self.icon = icon
    }

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
                    icon
                        .opacity(isHovering ? 1 : 0)
                }
                .padding(24)
                .allowsHitTesting(false)
            }
    }
}

public struct LuminareCompactButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.luminareAnimationFast) private var animationFast
    
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

public struct LuminareBordered: ViewModifier {
    @Binding var highlight: Bool
    let cornerRadius: CGFloat = 8

    public init(highlight: Binding<Bool> = .constant(false)) {
        self._highlight = highlight
    }

    public func body(content: Content) -> some View {
        content
            .background {
                if highlight {
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
