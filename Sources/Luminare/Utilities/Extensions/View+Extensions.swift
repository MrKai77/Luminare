//
//  View+Extensions.swift
//
//
//  Created by KrLite on 2024/11/3.
//

import SwiftUI

public extension View {
    /// Adjusts the tint of the view, synchronously changing the `.tint()` modifier and the `\.luminareTint` environment
    /// value.
    @ViewBuilder func overrideTint(_ tint: @escaping () -> Color) -> some View {
        self
            .tint(tint())
            .luminareTint(tint)
    }
}

// MARK: - Popover

public extension View {
    @ViewBuilder func luminarePopover(
        arrowEdge: Edge = .bottom,
        padding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        LuminarePopover(
            arrowEdge: arrowEdge,
            padding: padding,
            content: content
        ) {
            self
        }
    }
}

// MARK: - Popup

public extension View {
    @ViewBuilder func luminarePopup(
        material: NSVisualEffectView.Material = .popover,
        isPresented: Binding<Bool>
    ) -> some View {
        LuminarePopup(
            material: material,
            isPresented: isPresented
        ) {
            self
        }
    }
}

// MARK: - Modal

public extension View {
    @ViewBuilder func luminareModal(
        isPresented: Binding<Bool>,
        closesOnDefocus: Bool = false,
        isCompact: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminareModalModifier(
                isPresented: isPresented,
                closesOnDefocus: closesOnDefocus,
                isCompact: isCompact,
                content: content
            )
        )
    }
}

// MARK: - Background

public extension View {
    @ViewBuilder func luminareBackground() -> some View {
        modifier(LuminareBackgroundEffect())
    }
}

// MARK: - Environment Values

public extension View {
    @ViewBuilder func luminareTint(_ tint: @escaping () -> Color) -> some View {
        environment(\.luminareTint, tint)
    }

    @ViewBuilder func luminareAnimation(_ animation: Animation) -> some View {
        environment(\.luminareAnimation, animation)
    }

    @ViewBuilder func luminareAnimationFast(_ animation: Animation) -> some View {
        environment(\.luminareAnimationFast, animation)
    }
}

public extension View {
    @ViewBuilder func luminareCornerRadius(_ radius: CGFloat = 12) -> some View {
        environment(\.luminareCornerRadius, radius)
    }

    @ViewBuilder func luminareButtonCornerRadius(_ radius: CGFloat = 2) -> some View {
        environment(\.luminareButtonCornerRadius, radius)
    }
    
    @ViewBuilder func luminareCompactButtonCornerRadius(_ radius: CGFloat = 8) -> some View {
        environment(\.luminareCompactButtonCornerRadius, radius)
    }

    @ViewBuilder func luminareMinHeight(_ height: CGFloat = 34) -> some View {
        environment(\.luminareMinHeight, height)
    }

    @ViewBuilder func luminareHorizontalPadding(_ padding: CGFloat = 8) -> some View {
        environment(\.luminareHorizontalPadding, padding)
    }

    @ViewBuilder func luminareBordered(_ bordered: Bool = true) -> some View {
        environment(\.luminareIsBordered, bordered)
    }

    @ViewBuilder func luminareComposeControlSize(_ controlSize: LuminareComposeControlSize = .regular) -> some View {
        environment(\.luminareComposeControlSize, controlSize)
    }

    @ViewBuilder func luminarePopoverTrigger(_ trigger: LuminarePopoverTrigger = .hover) -> some View {
        environment(\.luminarePopoverTrigger, trigger)
    }

    @ViewBuilder func luminarePopoverShade(_ shade: LuminarePopoverShade = .styled) -> some View {
        environment(\.luminarePopoverShade, shade)
    }

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperAlignment(_ alignment: LuminareStepperAlignment = .trailing) -> some View {
        environment(\.luminareStepperAlignment, alignment)
    }

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperDirection(_ direction: LuminareStepperDirection = .horizontal) -> some View {
        environment(\.luminareStepperDirection, direction)
    }

    @ViewBuilder func luminareCompactPickerStyle(_ style: LuminareCompactPickerStyle = .menu) -> some View {
        environment(\.luminareCompactPickerStyle, style)
    }
}
