//
//  EnvironmentValues.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - Commons

public extension EnvironmentValues {
    // MARK: General

    // Currently, it is impossible to read the `.tint()` modifier on a view
    // this is a custom environement value as an alternative implementation of it
    // in practice, it should always be synchronized with `.tint()`
    @Entry var luminareTint: Color = .accentColor

    @Entry var luminareAnimation: Animation = .smooth(duration: 0.2)
    @Entry var luminareAnimationFast: Animation = .easeInOut(duration: 0.1)

    // MARK: Auxiliary

    @Entry var hoveringOverLuminareItem: Bool = false

    // MARK: Window

    @Entry var luminareWindow: NSWindow?
    @Entry var luminareWindowMinFrame: CGSize = .init(width: 100, height: 100)
    @Entry var luminareWindowMaxFrame: CGSize = .init(width: CGFloat.infinity, height: CGFloat.infinity)
    @Entry var luminareClickedOutside: Bool = false
}

// MARK: - Modals

public extension EnvironmentValues {
    // MARK: Modal

    @Entry var luminareModalStyle: LuminareModalStyle = .sheet
    @Entry var luminareModalContentWrapper: (AnyView) -> AnyView = { view in view }

    // MARK: Sheet

    @Entry var luminareSheetCornerRadii: RectangleCornerRadii = .init(12)
    @Entry var luminareSheetPresentation: LuminareSheetPresentation = .windowCenter
    @Entry var luminareSheetIsMovableByWindowBackground: Bool = false
    @Entry var luminareSheetClosesOnDefocus: Bool = false

    // MARK: Popup

    @Entry var luminarePopupPadding: CGFloat = 12
    @Entry var luminarePopupCornerRadii: RectangleCornerRadii = .init(
        topLeading: 12,
        bottomLeading: 12,
        bottomTrailing: 12,
        topTrailing: 12
    )

    // MARK: Color Picker

    @Entry var luminareColorPickerHasCancel: Bool = false
    @Entry var luminareColorPickerHasDone: Bool = false
}

// MARK: - Views

public extension EnvironmentValues {
    // MARK: General

    @Entry var luminareCornerRadii: RectangleCornerRadii = .init(12)
    @Entry var luminareMinHeight: CGFloat = 34
    @Entry var luminareHorizontalPadding: CGFloat = 8
    @Entry var luminareIsBordered: Bool = true
    @Entry var luminareHasDividers: Bool = true

    // MARK: Button Styles

    @Entry var luminareAspectRatio: (
        aspectRatio: CGFloat?,
        contentMode: ContentMode,
        hasFixedHeight: Bool
    )? = (nil, .fit, true)

    @Entry var luminareButtonMaterial: Material? = nil
    @Entry var luminareButtonCornerRadii: RectangleCornerRadii = .init(2)
    @Entry var luminareButtonHighlightOnHover: Bool = true

    @Entry var luminareCompactButtonCornerRadii: RectangleCornerRadii = .init(8)

    // MARK: Form Style

    @available(macOS 15.0, *)
    @Entry var luminareFormSpacing: CGFloat = 15

    // MARK: Pane

    @Entry var luminarePaneLayout: LuminarePaneLayout = .stacked
    @Entry var luminarePaneTitlebarHeight: CGFloat = 50

    // MARK: Section

    @Entry var luminareSectionLayout: LuminareSectionLayout = .stacked
    @Entry var luminareSectionMaterial: Material? = nil
    @Entry var luminareSectionMaxWidth: CGFloat? = .infinity
    @Entry var luminareSectionIsMasked: Bool = false

    // MARK: Compose

    @Entry var luminareComposeControlSize: LuminareComposeControlSize = .automatic
    @Entry var luminareComposeLayout: LuminareComposeLayout = .regular
    @Entry var luminareComposeStyle: LuminareComposeStyle = .automatic

    // MARK: Popover

    @Entry var luminarePopoverTrigger: LuminarePopoverTrigger = .hover
    @Entry var luminarePopoverShade: LuminarePopoverShade = .styled

    // MARK: Stepper

    @available(macOS 15.0, *)
    @Entry var luminareStepperAlignment: LuminareStepperAlignment = .trailing
    @available(macOS 15.0, *)
    @Entry var luminareStepperDirection: LuminareStepperDirection = .horizontal

    // MARK: Compact Picker

    @Entry var luminareCompactPickerStyle: LuminareCompactPickerStyle = .menu

    // MARK: List

    @Entry var luminareListContentMarginsTop: CGFloat = 0
    @Entry var luminareListContentMarginsBottom: CGFloat = 0
    @Entry var luminareListItemCornerRadii: RectangleCornerRadii = .init(2)
    @Entry var luminareListItemHeight: CGFloat = 50
    @Entry var luminareListItemHighlightOnHover: Bool = true
    @Entry var luminareListFixedHeightUntil: CGFloat? = nil
    @Entry var luminareListRoundedTopCornerBehavior: LuminareListRoundedCornerBehavior = .never
    @Entry var luminareListRoundedBottomCornerBehavior: LuminareListRoundedCornerBehavior = .never

    // MARK: Picker

    @Entry var luminarePickerRoundedTopCornerBehavior: LuminarePickerRoundedCornerBehavior = .never
    @Entry var luminarePickerRoundedBottomCornerBehavior: LuminarePickerRoundedCornerBehavior = .never
}
