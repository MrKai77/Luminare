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
    @ViewBuilder func overrideTint(_ tint: Color) -> some View {
        luminareTint(tint)
            .tint(tint)
    }

    @ViewBuilder func background(_ style: some ShapeStyle, with material: Material?) -> some View {
        background(material.map(AnyShapeStyle.init(_:)) ?? AnyShapeStyle(.clear))
            .background(style.opacity(material == nil ? 1 : 0.5))
    }

    @ViewBuilder func background(with material: Material?, @ViewBuilder _ content: () -> some View) -> some View {
        background(material.map(AnyShapeStyle.init(_:)) ?? AnyShapeStyle(.clear))
            .background {
                content()
                    .opacity(material == nil ? 1 : 0.5)
            }
    }
}

// MARK: - Popover

public extension View {
    @ViewBuilder func luminarePopover(
        arrowEdge: Edge = .bottom,
        padding: CGFloat = 4,
        @ViewBuilder _ content: @escaping () -> some View
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
        isPresented: Binding<Bool>,
        edge: Edge = .bottom,
        material: NSVisualEffectView.Material = .popover,
        @ViewBuilder _ content: @escaping () -> some View
    ) -> some View {
        background {
            LuminarePopup(
                isPresented: isPresented,
                edge: edge,
                material: material,
                content: content
            )
        }
    }
}

// MARK: - Modal

public extension View {
    @ViewBuilder func luminareModal(
        isPresented: Binding<Bool>,
        isMovableByWindowBackground: Bool = false,
        closesOnDefocus: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminareModalModifier(
                isPresented: isPresented,
                isMovableByWindowBackground: isMovableByWindowBackground,
                closesOnDefocus: closesOnDefocus,
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
    @ViewBuilder func luminareTint(_ tint: Color) -> some View {
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
    // MARK: General

    @ViewBuilder func luminareCornerRadius(_ radius: CGFloat = 12) -> some View {
        environment(\.luminareCornerRadius, radius)
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

    @ViewBuilder func luminareHasDividers(_ hasDividers: Bool = true) -> some View {
        environment(\.luminareHasDividers, hasDividers)
    }

    // MARK: Modal
    
    @ViewBuilder func luminareModalCornerRadius(_ radius: CGFloat = 12) -> some View {
        environment(\.luminareModalCornerRadius, radius)
    }
    
    @ViewBuilder func luminareModaePadding(_ padding: CGFloat = 12) -> some View {
        environment(\.luminareModalPadding, padding)
    }

    @ViewBuilder func luminareModalCancel(@ViewBuilder _ cancel: @escaping () -> (some View)?) -> some View {
        environment(\.luminareModalCancel) {
            cancel().map(AnyView.init(_:))
        }
    }

    @ViewBuilder func luminareModalDone(@ViewBuilder _ done: @escaping () -> (some View)?) -> some View {
        environment(\.luminareModalDone) {
            done().map(AnyView.init(_:))
        }
    }
    
    @ViewBuilder func luminareModalPresentation(_ presentation: LuminareModalPresentation) -> some View {
        environment(\.luminareModalPresentation, presentation)
    }

    // MARK: Luminare Button Styles

    @ViewBuilder func luminareButtonMaterial(_ material: Material? = nil) -> some View {
        environment(\.luminareButtonMaterial, material)
    }

    @ViewBuilder func luminareButtonCornerRadius(_ radius: CGFloat = 2) -> some View {
        environment(\.luminareButtonCornerRadius, radius)
    }

    @ViewBuilder func luminareButtonHighlightOnHover(_ highlight: Bool = true) -> some View {
        environment(\.luminareButtonHighlightOnHover, highlight)
    }

    @ViewBuilder func luminareCompactButtonCornerRadius(_ radius: CGFloat = 8) -> some View {
        environment(\.luminareCompactButtonCornerRadius, radius)
    }

    @ViewBuilder func luminareCompactButtonAspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) -> some View {
        environment(\.luminareCompactButtonAspectRatio, (aspectRatio, contentMode))
    }

    @ViewBuilder func luminareCompactButtonAspectRatio(_ aspectRatio: CGSize, contentMode: ContentMode) -> some View {
        environment(\.luminareCompactButtonAspectRatio, (aspectRatio.width / aspectRatio.height, contentMode))
    }

    @ViewBuilder func luminareCompactButtonHasFixedHeight(_ hasFixedHeight: Bool = true) -> some View {
        environment(\.luminareCompactButtonHasFixedHeight, hasFixedHeight)
    }

    // MARK: Luminare Section

    @ViewBuilder func luminareSectionMaterial(_ material: Material? = nil) -> some View {
        environment(\.luminareSectionMaterial, material)
    }

    @ViewBuilder func luminareSectionMaxWidth(_ maxWidth: CGFloat? = .infinity) -> some View {
        environment(\.luminareSectionMaxWidth, maxWidth)
    }

    @ViewBuilder func luminareSectionMasked(_ masked: Bool = false) -> some View {
        environment(\.luminareSectionIsMasked, masked)
    }

    // MARK: Luminare Compose

    @ViewBuilder func luminareComposeControlSize(_ controlSize: LuminareComposeControlSize = .regular) -> some View {
        environment(\.luminareComposeControlSize, controlSize)
    }

    @ViewBuilder func luminareComposeStyle(_ style: LuminareComposeStyle = .regular) -> some View {
        environment(\.luminareComposeStyle, style)
    }

    // MARK: Luminare Popover

    @ViewBuilder func luminarePopoverTrigger(_ trigger: LuminarePopoverTrigger = .hover) -> some View {
        environment(\.luminarePopoverTrigger, trigger)
    }

    @ViewBuilder func luminarePopoverShade(_ shade: LuminarePopoverShade = .styled) -> some View {
        environment(\.luminarePopoverShade, shade)
    }

    // MARK: Luminare Stepper

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperAlignment(_ alignment: LuminareStepperAlignment = .trailing) -> some View {
        environment(\.luminareStepperAlignment, alignment)
    }

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperDirection(_ direction: LuminareStepperDirection = .horizontal) -> some View {
        environment(\.luminareStepperDirection, direction)
    }

    // MARK: Luminare Compact Picker

    @ViewBuilder func luminareCompactPickerStyle(_ style: LuminareCompactPickerStyle = .menu) -> some View {
        environment(\.luminareCompactPickerStyle, style)
    }

    // MARK: Luminare List

    @ViewBuilder func luminareListContentMargins(_ margins: CGFloat) -> some View {
        luminareListContentMargins(top: margins, bottom: margins)
    }

    @ViewBuilder func luminareListContentMargins(top: CGFloat = 0, bottom: CGFloat = 0) -> some View {
        environment(\.luminareListContentMarginsTop, top)
            .environment(\.luminareListContentMarginsBottom, bottom)
    }

    @ViewBuilder func luminareListItemCornerRadius(_ radius: CGFloat = 2) -> some View {
        environment(\.luminareListItemCornerRadius, radius)
    }

    @ViewBuilder func luminareListItemHeight(_ height: CGFloat = 50) -> some View {
        environment(\.luminareListItemHeight, height)
    }

    @ViewBuilder func luminareListItemHighlightOnHover(_ highlight: Bool = true) -> some View {
        environment(\.luminareListItemHighlightOnHover, highlight)
    }
}
