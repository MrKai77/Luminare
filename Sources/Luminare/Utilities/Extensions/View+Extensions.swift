//
//  View+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/11/3.
//

import SwiftUI

// MARK: - Internal

extension View {
    // Applies a transform to the view
    @ViewBuilder func applying(@ViewBuilder _ transform: @escaping (Self) -> some View) -> some View {
        transform(self)
    }

    // Assigns the specified environment value, if not nil
    @ViewBuilder func assigning<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        _ value: V?
    ) -> some View {
        if let value {
            environment(keyPath, value)
        } else {
            self
        }
    }

    // Applies a materialized background over a style
    @ViewBuilder func background(_ style: some ShapeStyle, with material: Material?) -> some View {
        background(material.map(AnyShapeStyle.init(_:)) ?? AnyShapeStyle(.clear))
            .background(style)
    }

    // Applies a materialized background over a view
    @ViewBuilder func background(with material: Material?, @ViewBuilder _ content: () -> some View) -> some View {
        background(material.map(AnyShapeStyle.init(_:)) ?? AnyShapeStyle(.clear))
            .background {
                content()
            }
    }
}

// MARK: - Convenient Wrapper

public extension View {
    // MARK: Popover

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

    // MARK: Popup

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

    // MARK: Modal

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

// MARK: - Common

public extension View {
    /// Adjusts the tint of the view, synchronously changing the `.tint()` modifier and the `\.luminareTint` environment
    /// value.
    @ViewBuilder func overrideTint(_ tint: Color) -> some View {
        luminareTint(tint)
            .tint(tint)
    }

    @ViewBuilder func luminareBackground() -> some View {
        modifier(LuminareBackgroundEffect())
    }

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

// MARK: - Modal

public extension View {
    @ViewBuilder func luminareModalStyle(_ style: LuminareModalStyle) -> some View {
        environment(\.luminareModalStyle, style)
    }

    @ViewBuilder func luminareModalContentWrapper(@ViewBuilder _ content: @escaping (AnyView) -> some View) -> some View {
        environment(\.luminareModalContentWrapper) { view in
            AnyView(content(view))
        }
    }

    // MARK: Sheet

    @ViewBuilder func luminareSheetCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareSheetCornerRadii, radii)
    }

    @ViewBuilder func luminareSheetCornerRadius(_ radius: CGFloat) -> some View {
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

    @ViewBuilder func luminarePopupCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminarePopupCornerRadii, radii)
    }

    // MARK: Color Picker

    @ViewBuilder func luminareColorPickerControls(hasCancel: Bool? = nil, hasDone: Bool? = nil) -> some View {
        assigning(\.luminareColorPickerHasCancel, hasCancel)
            .assigning(\.luminareColorPickerHasDone, hasDone)
    }
}

// MARK: - View

public extension View {
    @ViewBuilder func luminareCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareCornerRadii, radii)
    }

    @ViewBuilder func luminareCornerRadius(_ radius: CGFloat) -> some View {
        luminareCornerRadii(.init(radius))
    }

    @ViewBuilder func luminareMinHeight(_ height: CGFloat) -> some View {
        environment(\.luminareMinHeight, height)
    }

    @ViewBuilder func luminareHorizontalPadding(_ padding: CGFloat) -> some View {
        environment(\.luminareHorizontalPadding, padding)
    }

    @ViewBuilder func luminareBordered(_ bordered: Bool) -> some View {
        environment(\.luminareIsBordered, bordered)
    }

    @ViewBuilder func luminareHasBackground(_ hasBackground: Bool) -> some View {
        environment(\.luminareHasBackground, hasBackground)
    }

    @ViewBuilder func luminareHasDividers(_ hasDividers: Bool) -> some View {
        environment(\.luminareHasDividers, hasDividers)
    }

    @ViewBuilder func luminareAspectRatio(unapplying: Bool) -> some View {
        if unapplying {
            environment(\.luminareAspectRatioContentMode, nil)
        } else {
            self
        }
    }

    @ViewBuilder func luminareAspectRatio(
        _ aspectRatio: CGFloat? = nil, contentMode: ContentMode, hasFixedHeight: Bool? = nil
    ) -> some View {
        environment(\.luminareAspectRatio, aspectRatio)
            .environment(\.luminareAspectRatioContentMode, contentMode)
            .assigning(\.luminareAspectRatioHasFixedHeight, hasFixedHeight)
    }

    @ViewBuilder func luminareAspectRatio(
        _ aspectRatio: CGSize, contentMode: ContentMode, hasFixedHeight: Bool? = nil
    ) -> some View {
        luminareAspectRatio(
            aspectRatio.width / aspectRatio.height,
            contentMode: contentMode,
            hasFixedHeight: hasFixedHeight
        )
    }

    @ViewBuilder func luminareContentMargins(_ insets: EdgeInsets) -> some View {
        environment(\.luminareContentMarginsTop, insets.top)
            .environment(\.luminareContentMarginsLeading, insets.leading)
            .environment(\.luminareContentMarginsBottom, insets.bottom)
            .environment(\.luminareContentMarginsTrailing, insets.trailing)
    }

    @ViewBuilder func luminareContentMargins(_ edges: Edge.Set, _ length: CGFloat) -> some View {
        assigning(\.luminareContentMarginsTop, edges.contains(.top) ? length : nil)
            .assigning(\.luminareContentMarginsLeading, edges.contains(.leading) ? length : nil)
            .assigning(\.luminareContentMarginsBottom, edges.contains(.bottom) ? length : nil)
            .assigning(\.luminareContentMarginsTrailing, edges.contains(.trailing) ? length : nil)
    }

    @ViewBuilder func luminareContentMargins(_ length: CGFloat) -> some View {
        luminareContentMargins(.all, length)
    }

    // MARK: Button

    @ViewBuilder func luminareButtonMaterial(_ material: Material?) -> some View {
        environment(\.luminareButtonMaterial, material)
    }

    @ViewBuilder func luminareButtonCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareButtonCornerRadii, radii)
    }

    @ViewBuilder func luminareButtonCornerRadius(_ radius: CGFloat) -> some View {
        luminareButtonCornerRadii(.init(radius))
    }

    @ViewBuilder func luminareButtonHighlightOnHover(_ highlight: Bool) -> some View {
        environment(\.luminareButtonHighlightOnHover, highlight)
    }

    @ViewBuilder func luminareCompactButtonCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareCompactButtonCornerRadii, radii)
    }

    @ViewBuilder func luminareCompactButtonCornerRadius(_ radius: CGFloat) -> some View {
        luminareCompactButtonCornerRadii(.init(radius))
    }

    // MARK: Form

    @available(macOS 15.0, *)
    @ViewBuilder func luminareFormSpacing(_ spacing: CGFloat) -> some View {
        environment(\.luminareFormSpacing, spacing)
    }

    // MARK: Pane

    @ViewBuilder func luminarePaneLayout(_ layout: LuminarePaneLayout) -> some View {
        environment(\.luminarePaneLayout, layout)
    }

    @ViewBuilder func luminarePaneTitlebarHeight(_ height: CGFloat) -> some View {
        environment(\.luminarePaneTitlebarHeight, height)
    }

    // MARK: Section

    @ViewBuilder func luminareSectionLayout(_ layout: LuminareSectionLayout) -> some View {
        environment(\.luminareSectionLayout, layout)
    }

    @ViewBuilder func luminareSectionMaterial(_ material: Material?) -> some View {
        environment(\.luminareSectionMaterial, material)
    }

    @ViewBuilder func luminareSectionMaxWidth(_ maxWidth: CGFloat?) -> some View {
        environment(\.luminareSectionMaxWidth, maxWidth)
    }

    @ViewBuilder func luminareSectionMasked(_ masked: Bool) -> some View {
        environment(\.luminareSectionIsMasked, masked)
    }

    // MARK: Compose

    @ViewBuilder func luminareComposeControlSize(_ controlSize: LuminareComposeControlSize) -> some View {
        environment(\.luminareComposeControlSize, controlSize)
    }

    @ViewBuilder func luminareComposeLayout(_ layout: LuminareComposeLayout) -> some View {
        environment(\.luminareComposeLayout, layout)
    }

    @ViewBuilder func luminareComposeStyle(_ style: LuminareComposeStyle) -> some View {
        environment(\.luminareComposeStyle, style)
    }

    // MARK: Popover

    @ViewBuilder func luminarePopoverTrigger(_ trigger: LuminarePopoverTrigger) -> some View {
        environment(\.luminarePopoverTrigger, trigger)
    }

    @ViewBuilder func luminarePopoverShade(_ shade: LuminarePopoverShade) -> some View {
        environment(\.luminarePopoverShade, shade)
    }

    // MARK: Stepper

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperAlignment(_ alignment: LuminareStepperAlignment) -> some View {
        environment(\.luminareStepperAlignment, alignment)
    }

    @available(macOS 15.0, *)
    @ViewBuilder func luminareStepperDirection(_ direction: LuminareStepperDirection) -> some View {
        environment(\.luminareStepperDirection, direction)
    }

    // MARK: Compact Picker

    @ViewBuilder func luminareCompactPickerStyle(_ style: LuminareCompactPickerStyle) -> some View {
        environment(\.luminareCompactPickerStyle, style)
    }

    // MARK: List

    @ViewBuilder func luminareListItemCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareListItemCornerRadii, radii)
    }

    @ViewBuilder func luminareListItemCornerRadius(_ radius: CGFloat) -> some View {
        luminareListItemCornerRadii(.init(radius))
    }

    @ViewBuilder func luminareListItemHeight(_ height: CGFloat) -> some View {
        environment(\.luminareListItemHeight, height)
    }

    @ViewBuilder func luminareListItemHighlightOnHover(_ highlight: Bool) -> some View {
        environment(\.luminareListItemHighlightOnHover, highlight)
    }

    @ViewBuilder func luminareListFixedHeight(until height: CGFloat?) -> some View {
        environment(\.luminareListFixedHeightUntil, height)
    }

    @ViewBuilder func luminareListRoundedCorner(
        top: LuminareListRoundedCornerBehavior? = nil,
        bottom: LuminareListRoundedCornerBehavior? = nil
    ) -> some View {
        assigning(\.luminareListRoundedTopCornerBehavior, top)
            .assigning(\.luminareListRoundedBottomCornerBehavior, bottom)
    }

    @ViewBuilder func luminareListRoundedCorner(_ all: LuminareListRoundedCornerBehavior) -> some View {
        luminareListRoundedCorner(top: all, bottom: all)
    }

    // MARK: Picker

    @ViewBuilder func luminarePickerRoundedCorner(
        top: LuminarePickerRoundedCornerBehavior? = nil,
        bottom: LuminarePickerRoundedCornerBehavior? = nil
    ) -> some View {
        assigning(\.luminarePickerRoundedTopCornerBehavior, top)
            .assigning(\.luminarePickerRoundedBottomCornerBehavior, bottom)
    }

    @ViewBuilder func luminarePickerRoundedCorner(_ all: LuminarePickerRoundedCornerBehavior) -> some View {
        luminarePickerRoundedCorner(top: all, bottom: all)
    }

    // MARK: Sidebar

    @ViewBuilder func luminareSizebarOverflow(_ overflow: CGFloat) -> some View {
        environment(\.luminareSidebarOverflow, overflow)
    }
}
