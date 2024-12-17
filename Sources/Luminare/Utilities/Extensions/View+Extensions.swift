//
//  View+Extensions.swift
//  Luminare
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
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminareModalModifier(
                isPresented: isPresented,
                content: content
            )
        )
    }

    @ViewBuilder func luminareModalWithPredefinedSheetStyle(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminareModalModifier(
                isPresented: isPresented
            ) {
                content()
                    .padding(8)
            }
        )
        .luminareSheetCornerRadii(.init(topLeading: 18, bottomLeading: 14, bottomTrailing: 14, topTrailing: 18))
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
    // MARK: Modal

    @ViewBuilder func luminareModalStyle(_ style: LuminareModalStyle) -> some View {
        environment(\.luminareModalStyle, style)
    }

    @ViewBuilder func luminareModalContentWrapper(@ViewBuilder _ content: @escaping (AnyView) -> some View) -> some View {
        environment(\.luminareModalContentWrapper) { view in
            AnyView(content(view))
        }
    }

    // MARK: Sheet

    @ViewBuilder func luminareSheetCornerRadii(_ radii: RectangleCornerRadii = .init(12)) -> some View {
        environment(\.luminareSheetCornerRadii, radii)
    }

    @ViewBuilder func luminareSheetCornerRadius(_ radius: CGFloat = 12) -> some View {
        luminareSheetCornerRadii(.init(radius))
    }

    @ViewBuilder func luminareSheetPresentation(_ presentation: LuminareSheetPresentation) -> some View {
        environment(\.luminareSheetPresentation, presentation)
    }

    @ViewBuilder func luminareSheetMovableByWindowBackground(_ movable: Bool = true) -> some View {
        environment(\.luminareSheetIsMovableByWindowBackground, movable)
    }

    @ViewBuilder func luminareSheetClosesOnDefocus(_ closesOnDefocus: Bool = true) -> some View {
        environment(\.luminareSheetClosesOnDefocus, closesOnDefocus)
    }

    // MARK: Popup

    @ViewBuilder func luminarePopupPadding(_ padding: CGFloat = 12) -> some View {
        environment(\.luminarePopupPadding, padding)
    }

    @ViewBuilder func luminarePopupCornerRadii(_ radii: RectangleCornerRadii = .init(topLeading: 12, bottomLeading: 12, bottomTrailing: 12, topTrailing: 12)) -> some View {
        environment(\.luminarePopupCornerRadii, radii)
    }

    // MARK: Color Picker

    @ViewBuilder func luminareColorPickerControls(hasCancel: Bool = false, hasDone: Bool = false) -> some View {
        environment(\.luminareColorPickerHasCancel, hasCancel)
            .environment(\.luminareColorPickerHasDone, hasDone)
    }
}

public extension View {
    // MARK: General

    @ViewBuilder func luminareCornerRadii(_ radii: RectangleCornerRadii = .init(12)) -> some View {
        environment(\.luminareCornerRadii, radii)
    }

    @ViewBuilder func luminareCornerRadius(_ radius: CGFloat = 12) -> some View {
        luminareCornerRadii(.init(radius))
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

    // MARK: Pane

    @ViewBuilder func luminarePaneTitlebarHeight(_ height: CGFloat = 50) -> some View {
        environment(\.luminarePaneTitlebarHeight, height)
    }

    @ViewBuilder func luminarePaneSpacing(_ spacing: CGFloat = 15) -> some View {
        environment(\.luminarePaneSpacing, spacing)
    }

    // MARK: Button Styles

    @ViewBuilder func luminareButtonMaterial(_ material: Material? = nil) -> some View {
        environment(\.luminareButtonMaterial, material)
    }

    @ViewBuilder func luminareButtonCornerRadii(_ radii: RectangleCornerRadii = .init(2)) -> some View {
        environment(\.luminareButtonCornerRadii, radii)
    }

    @ViewBuilder func luminareButtonCornerRadius(_ radius: CGFloat = 2) -> some View {
        luminareButtonCornerRadii(.init(radius))
    }

    @ViewBuilder func luminareButtonHighlightOnHover(_ highlight: Bool = true) -> some View {
        environment(\.luminareButtonHighlightOnHover, highlight)
    }

    @ViewBuilder func luminareCompactButtonCornerRadii(_ radii: RectangleCornerRadii = .init(8)) -> some View {
        environment(\.luminareCompactButtonCornerRadii, radii)
    }

    @ViewBuilder func luminareCompactButtonCornerRadius(_ radius: CGFloat = 8) -> some View {
        luminareCompactButtonCornerRadii(.init(radius))
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

    // MARK: Section

    @ViewBuilder func luminareSectionLayout(_ layout: LuminareSectionLayout = .stacked) -> some View {
        environment(\.luminareSectionLayout, layout)
    }

    @ViewBuilder func luminareSectionMaterial(_ material: Material? = nil) -> some View {
        environment(\.luminareSectionMaterial, material)
    }

    @ViewBuilder func luminareSectionMaxWidth(_ maxWidth: CGFloat? = .infinity) -> some View {
        environment(\.luminareSectionMaxWidth, maxWidth)
    }

    @ViewBuilder func luminareSectionMasked(_ masked: Bool = false) -> some View {
        environment(\.luminareSectionIsMasked, masked)
    }

    // MARK: Compose

    @ViewBuilder func luminareComposeControlSize(_ controlSize: LuminareComposeControlSize = .automatic) -> some View {
        environment(\.luminareComposeControlSize, controlSize)
    }

    @ViewBuilder func luminareComposeLayout(_ layout: LuminareComposeLayout = .regular) -> some View {
        environment(\.luminareComposeLayout, layout)
    }

    @ViewBuilder func luminareComposeStyle(_ style: LuminareComposeStyle = .automatic) -> some View {
        environment(\.luminareComposeStyle, style)
    }

    // MARK: Popover

    @ViewBuilder func luminarePopoverTrigger(_ trigger: LuminarePopoverTrigger = .hover) -> some View {
        environment(\.luminarePopoverTrigger, trigger)
    }

    @ViewBuilder func luminarePopoverShade(_ shade: LuminarePopoverShade = .styled) -> some View {
        environment(\.luminarePopoverShade, shade)
    }

    // MARK: Stepper

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperAlignment(_ alignment: LuminareStepperAlignment = .trailing) -> some View {
        environment(\.luminareStepperAlignment, alignment)
    }

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperDirection(_ direction: LuminareStepperDirection = .horizontal) -> some View {
        environment(\.luminareStepperDirection, direction)
    }

    // MARK: Compact Picker

    @ViewBuilder func luminareCompactPickerStyle(_ style: LuminareCompactPickerStyle = .menu) -> some View {
        environment(\.luminareCompactPickerStyle, style)
    }

    // MARK: List

    @ViewBuilder func luminareListContentMargins(_ margins: CGFloat) -> some View {
        luminareListContentMargins(top: margins, bottom: margins)
    }

    @ViewBuilder func luminareListContentMargins(top: CGFloat = 0, bottom: CGFloat = 0) -> some View {
        environment(\.luminareListContentMarginsTop, top)
            .environment(\.luminareListContentMarginsBottom, bottom)
    }

    @ViewBuilder func luminareListItemCornerRadii(_ radii: RectangleCornerRadii = .init(2)) -> some View {
        environment(\.luminareListItemCornerRadii, radii)
    }

    @ViewBuilder func luminareListItemCornerRadius(_ radius: CGFloat = 2) -> some View {
        luminareListItemCornerRadii(.init(radius))
    }

    @ViewBuilder func luminareListItemHeight(_ height: CGFloat = 50) -> some View {
        environment(\.luminareListItemHeight, height)
    }

    @ViewBuilder func luminareListItemHighlightOnHover(_ highlight: Bool = true) -> some View {
        environment(\.luminareListItemHighlightOnHover, highlight)
    }

    @ViewBuilder func luminareListFixedHeight(until height: CGFloat? = nil) -> some View {
        environment(\.luminareListFixedHeightUntil, height)
    }

    @ViewBuilder func luminareListRoundedCorner(top: LuminareListRoundedCornerBehavior = .never, bottom: LuminareListRoundedCornerBehavior = .never) -> some View {
        environment(\.luminareListRoundedTopCornerBehavior, top)
            .environment(\.luminareListRoundedBottomCornerBehavior, bottom)
    }

    @ViewBuilder func luminareListRoundedCorner(_ all: LuminareListRoundedCornerBehavior = .never) -> some View {
        luminareListRoundedCorner(top: all, bottom: all)
    }

    // MARK: Picker

    @ViewBuilder func luminarePickerRoundedCorner(top: LuminarePickerRoundedCornerBehavior = .never, bottom: LuminarePickerRoundedCornerBehavior = .never) -> some View {
        environment(\.luminarePickerRoundedTopCornerBehavior, top)
            .environment(\.luminarePickerRoundedBottomCornerBehavior, bottom)
    }

    @ViewBuilder func luminarePickerRoundedCorner(_ all: LuminarePickerRoundedCornerBehavior = .never) -> some View {
        luminarePickerRoundedCorner(top: all, bottom: all)
    }
}
