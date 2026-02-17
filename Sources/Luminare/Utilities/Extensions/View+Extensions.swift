//
//  View+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/11/3.
//

import SwiftUI

// MARK: - Internal

extension View {
    /// Assigns the specified environment value, if not nil
    @ViewBuilder func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        ifNotNil value: V?
    ) -> some View {
        if let value {
            environment(keyPath, value)
        } else {
            self
        }
    }

    func readPreference<K>(
        _ key: K.Type = K.self,
        to binding: Binding<K.Value>
    ) -> some View where K: PreferenceKey, K.Value: Equatable {
        onPreferenceChange(key) { value in
            binding.wrappedValue = value
        }
    }
}

// MARK: - Convenient Wrappers

public extension View {
    // MARK: Popover

    @ViewBuilder func luminareToolTip(
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil,
        padding: CGFloat = 4,
        hidden: Bool = false,
        @ViewBuilder toolTipContent: @escaping () -> some View
    ) -> some View {
        if !hidden {
            modifier(LuminareToolTipModifier(
                attachmentAnchor: attachmentAnchor,
                arrowEdge: arrowEdge,
                padding: padding,
                toolTipContent: toolTipContent
            ))
        }
    }

    func luminareToolTip(
        attachedTo alignment: Alignment,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge? = nil,
        padding: CGFloat = 4,
        dotSize: CGFloat = 4,
        hidden: Bool = false,
        @ViewBuilder toolTipContent: @escaping () -> some View
    ) -> some View {
        overlay(alignment: alignment) {
            Color.clear
                .frame(width: 0, height: 0)
                .overlay {
                    Circle()
                        .foregroundStyle(.tint)
                        .frame(width: dotSize, height: dotSize)
                        .padding(2)
                        .luminareToolTip(
                            attachmentAnchor: attachmentAnchor,
                            arrowEdge: arrowEdge,
                            padding: padding,
                            hidden: hidden,
                            toolTipContent: toolTipContent
                        )
                }
        }
    }

    // MARK: Popover

    func luminarePopover(
        isPresented: Binding<Bool>,
        arrowEdge: Edge = .bottom,
        behavior: NSPopover.Behavior = .semitransient,
        shouldHideAnchor: Bool? = nil,
        shouldAnimate: Bool = true,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminarePopoverModifier(
                isPresented: isPresented,
                arrowEdge: arrowEdge,
                behavior: behavior,
                shouldHideAnchor: shouldHideAnchor,
                shouldAnimate: shouldAnimate,
                popoverContent: content
            )
        )
    }

    // MARK: Modal

    func luminareModal(
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

    func luminareModalWithPredefinedSheetStyle(
        isPresented: Binding<Bool>,
        isCompact: Bool = true,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            LuminareModalModifier(
                isPresented: isPresented
            ) {
                content()
                    .padding(isCompact ? 8 : 16)
            }
        )
        .luminareSheetCornerRadii(
            .init(
                topLeading: 12 + (isCompact ? 8 : 16),
                bottomLeading: 8 + (isCompact ? 8 : 16),
                bottomTrailing: 8 + (isCompact ? 8 : 16),
                topTrailing: 12 + (isCompact ? 8 : 16)
            )
        )
    }

    func booleanThrottleDebounced(
        _ value: Bool,
        flipOnDelay: TimeInterval = 0.5,
        flipOffDelay: TimeInterval = .zero,
        throttleDelay: TimeInterval = 0.25,
        initial: Bool = false,
        action: @escaping (Bool) -> ()
    ) -> some View {
        modifier(BooleanThrottleDebouncedModifier(
            value,
            flipOnDelay: flipOnDelay,
            flipOffDelay: flipOffDelay,
            throttleDelay: throttleDelay,
            initial: initial,
            action: action
        ))
    }

    func luminareContentSize(
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode? = nil,
        hasFixedHeight: Bool = false
    ) -> some View {
        modifier(
            LuminareContentSizeModifier(
                aspectRatio: aspectRatio,
                contentMode: contentMode,
                hasFixedHeight: hasFixedHeight
            )
        )
    }

    func luminarePlateau(
        isPressed: Bool = false,
        isHovering: Bool = false,
        overrideFillStyle: LuminareFillStyle<AnyShapeStyle, AnyShapeStyle, AnyShapeStyle>? = nil,
        overrideBorderStyle: LuminareBorderStyle<AnyShapeStyle, AnyShapeStyle>? = nil
    ) -> some View {
        modifier(
            LuminarePlateauModifier(
                isPressed: isPressed,
                isHovering: isHovering,
                overrideFillStyle: overrideFillStyle,
                overrideBorderStyle: overrideBorderStyle
            )
        )
    }

    func luminareBackground() -> some View {
        modifier(
            LuminareBackgroundEffectModifier()
        )
    }
}

// MARK: - Common

public extension View {
    /// Adjusts the tint of the view, synchronously changing the `.tint()` modifier and the `luminareTintColor` environment
    /// value.
    func luminareTint(overridingWith color: Color) -> some View {
        tint(color)
            .environment(\.luminareTintColor, color)
    }

    func luminareAnimation(_ animation: Animation) -> some View {
        environment(\.luminareAnimation, animation)
    }

    func luminareAnimationFast(_ animation: Animation) -> some View {
        environment(\.luminareAnimationFast, animation)
    }
}

// MARK: - Modals

public extension View {
    func luminareModalStyle(_ style: LuminareModalStyle) -> some View {
        environment(\.luminareModalStyle, style)
    }

    func luminareModalContentWrapper(@ViewBuilder content: @escaping (AnyView) -> some View) -> some View {
        environment(\.luminareModalContentWrapper) { view in
            AnyView(content(view))
        }
    }

    // MARK: Sheet

    func luminareSheetCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareSheetCornerRadii, radii)
    }

    func luminareSheetCornerRadius(_ radius: CGFloat) -> some View {
        luminareSheetCornerRadii(.init(radius))
    }

    func luminareSheetPresentation(_ presentation: LuminareSheetPresentation) -> some View {
        environment(\.luminareSheetPresentation, presentation)
    }

    func luminareSheetMovableByWindowBackground(_ movable: Bool = true) -> some View {
        environment(\.luminareSheetIsMovableByWindowBackground, movable)
    }

    func luminareSheetClosesOnDefocus(_ closesOnDefocus: Bool = true) -> some View {
        environment(\.luminareSheetClosesOnDefocus, closesOnDefocus)
    }

    // MARK: Popup

    func luminarePopupPadding(_ padding: CGFloat = 4) -> some View {
        environment(\.luminarePopupPadding, padding)
    }

    func luminarePopupCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminarePopupCornerRadii, radii)
    }

    // MARK: Color Picker

    func luminareColorPickerControls(hasCancel: Bool? = nil, hasDone: Bool? = nil) -> some View {
        environment(\.luminareColorPickerHasCancel, ifNotNil: hasCancel)
            .environment(\.luminareColorPickerHasDone, ifNotNil: hasDone)
    }
}

// MARK: - View

public extension View {
    func luminareCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareCornerRadii, radii)
    }

    func luminareCornerRadius(_ radius: CGFloat) -> some View {
        luminareCornerRadii(.init(radius))
            .environment(\.luminareIsInsideSection, false)
    }

    func luminareMinHeight(_ height: CGFloat) -> some View {
        environment(\.luminareMinHeight, height)
    }

    func luminareBorderedStates(_ states: LuminareBorderStates) -> some View {
        environment(\.luminareBorderedStates, states)
    }

    func luminareFilledStates(_ states: LuminareFillStates) -> some View {
        environment(\.luminareFilledStates, states)
    }

    func luminareHasDividers(_ hasDividers: Bool) -> some View {
        environment(\.luminareHasDividers, hasDividers)
    }

    func luminareContentMargins(_ insets: EdgeInsets) -> some View {
        environment(\.luminareContentMarginsTop, insets.top)
            .environment(\.luminareContentMarginsLeading, insets.leading)
            .environment(\.luminareContentMarginsBottom, insets.bottom)
            .environment(\.luminareContentMarginsTrailing, insets.trailing)
    }

    func luminareContentMargins(_ edges: Edge.Set, _ length: CGFloat) -> some View {
        environment(\.luminareContentMarginsTop, ifNotNil: edges.contains(.top) ? length : nil)
            .environment(\.luminareContentMarginsLeading, ifNotNil: edges.contains(.leading) ? length : nil)
            .environment(\.luminareContentMarginsBottom, ifNotNil: edges.contains(.bottom) ? length : nil)
            .environment(\.luminareContentMarginsTrailing, ifNotNil: edges.contains(.trailing) ? length : nil)
    }

    func luminareContentMargins(_ length: CGFloat) -> some View {
        luminareContentMargins(.all, length)
    }

    // MARK: Form

    @available(macOS 15.0, *)
    func luminareFormSpacing(_ spacing: CGFloat) -> some View {
        environment(\.luminareFormSpacing, spacing)
    }

    // MARK: Pane

    func luminarePaneLayout(_ layout: LuminarePaneLayout) -> some View {
        environment(\.luminarePaneLayout, layout)
    }

    func luminareTitleBarHeight(_ height: CGFloat) -> some View {
        environment(\.luminareTitleBarHeight, height)
    }

    // MARK: Section

    func luminareSectionLayout(_ layout: LuminareSectionLayout) -> some View {
        environment(\.luminareSectionLayout, layout)
    }

    func luminareSectionHorizontalPadding(_ padding: CGFloat) -> some View {
        environment(\.luminareSectionHorizontalPadding, padding)
    }

    func luminareRoundingBehavior(
        topLeading: Bool? = nil,
        topTrailing: Bool? = nil,
        bottomLeading: Bool? = nil,
        bottomTrailing: Bool? = nil
    ) -> some View {
        environment(\.luminareTopLeadingRounded, ifNotNil: topLeading)
            .environment(\.luminareTopTrailingRounded, ifNotNil: topTrailing)
            .environment(\.luminareBottomLeadingRounded, ifNotNil: bottomLeading)
            .environment(\.luminareBottomTrailingRounded, ifNotNil: bottomTrailing)
    }

    func luminareRoundingBehavior(
        top: Bool? = nil,
        bottom: Bool? = nil
    ) -> some View {
        environment(\.luminareTopLeadingRounded, ifNotNil: top)
            .environment(\.luminareTopTrailingRounded, ifNotNil: top)
            .environment(\.luminareBottomLeadingRounded, ifNotNil: bottom)
            .environment(\.luminareBottomTrailingRounded, ifNotNil: bottom)
    }

    func luminareRoundingBehavior(
        leading: Bool? = nil,
        trailing: Bool? = nil
    ) -> some View {
        environment(\.luminareTopLeadingRounded, ifNotNil: leading)
            .environment(\.luminareTopTrailingRounded, ifNotNil: trailing)
            .environment(\.luminareBottomLeadingRounded, ifNotNil: leading)
            .environment(\.luminareBottomTrailingRounded, ifNotNil: trailing)
    }

    func luminareSectionMaxWidth(_ maxWidth: CGFloat?) -> some View {
        environment(\.luminareSectionMaxWidth, maxWidth)
    }

    func luminareSectionDisableInnerPadding(_ disable: Bool) -> some View {
        preference(key: LuminareSectionStackDisableInnerPaddingKey.self, value: disable)
    }

    // MARK: Compose

    func luminareComposeControlSize(_ controlSize: LuminareComposeControlSize) -> some View {
        environment(\.luminareComposeControlSize, controlSize)
    }

    func luminareComposeIgnoreSafeArea(edges: Edge.Set) -> some View {
        preference(
            key: LuminareComposeIgnoreSafeAreaEdgesKey.self,
            value: edges
        )
    }

    // MARK: Tool Tip

    func luminareToolTipTrigger(_ trigger: LuminareToolTipTrigger) -> some View {
        environment(\.luminareToolTipTrigger, trigger)
    }

    func luminareToolTipShade(_ shade: LuminareToolTipShade) -> some View {
        environment(\.luminareToolTipShade, shade)
    }

    // MARK: Stepper

    @available(macOS 15.0, *)
    func luminareStepperAlignment(_ alignment: LuminareStepperAlignment) -> some View {
        environment(\.luminareStepperAlignment, alignment)
    }

    @available(macOS 15.0, *)
    func luminareStepperDirection(_ direction: LuminareStepperDirection) -> some View {
        environment(\.luminareStepperDirection, direction)
    }

    // MARK: Compact Picker

    func luminareCompactPickerStyle(_ style: LuminareCompactPickerStyle) -> some View {
        environment(\.luminareCompactPickerStyle, style)
    }

    // MARK: List

    func luminareListItemCornerRadii(_ radii: RectangleCornerRadii) -> some View {
        environment(\.luminareListItemCornerRadii, radii)
    }

    func luminareListItemCornerRadius(_ radius: CGFloat) -> some View {
        luminareListItemCornerRadii(.init(radius))
    }

    func luminareListItemHeight(_ height: CGFloat) -> some View {
        environment(\.luminareListItemHeight, height)
    }

    func luminareListItemHighlightOnHover(_ highlight: Bool) -> some View {
        environment(\.luminareListItemHighlightOnHover, highlight)
    }

    func luminareListFixedHeight(until height: CGFloat?) -> some View {
        environment(\.luminareListFixedHeightUntil, height)
    }

    // MARK: Sidebar

    func luminareSizebarOverflow(_ overflow: CGFloat) -> some View {
        environment(\.luminareSidebarOverflow, overflow)
    }

    // MARK: Slider

    func luminareSliderLayout(_ layout: LuminareSliderLayout) -> some View {
        environment(\.luminareSliderLayout, layout)
    }

    // MARK: Slider Picker

    func luminareSliderPickerLayout(_ layout: LuminareSliderPickerLayout) -> some View {
        environment(\.luminareSliderPickerLayout, layout)
    }
}
