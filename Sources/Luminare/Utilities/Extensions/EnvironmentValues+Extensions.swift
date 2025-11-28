//
//  EnvironmentValues+Extensions.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - Internal

extension EnvironmentValues {
    @Entry var luminareWindow: LuminareWindow?

    @Entry var luminareClickedOutside: Bool = false
}

// MARK: - Common

public extension EnvironmentValues {
    // Currently, it is impossible to read the `.tint()` modifier on a view
    // this is a custom environement value as an alternative implementation of it
    // in practice, it should always be synchronized with `.tint()`
    @Entry var luminareTintColor: Color = .accentColor

    @Entry var luminareAnimation: Animation = .smooth(duration: 0.2)
    @Entry var luminareAnimationFast: Animation = .easeInOut(duration: 0.1)
}

// MARK: - Modal

public extension EnvironmentValues {
    @Entry var luminareModalStyle: LuminareModalStyle = .sheet
    @Entry var luminareModalContentWrapper: (AnyView) -> AnyView = { view in view }

    // MARK: Sheet

    @Entry var luminareSheetCornerRadii: RectangleCornerRadii = .init(12)

    @Entry var luminareSheetPresentation: LuminareSheetPresentation = .windowCenter
    @Entry var luminareSheetIsMovableByWindowBackground: Bool = false
    @Entry var luminareSheetClosesOnDefocus: Bool = false

    // MARK: Popup

    @Entry var luminarePopupCornerRadii: RectangleCornerRadii = .init(16)
    @Entry var luminarePopupPadding: CGFloat = 4

    // MARK: Color Picker

    @Entry var luminareColorPickerHasCancel: Bool = false
    @Entry var luminareColorPickerHasDone: Bool = false
}

// MARK: - View

public extension EnvironmentValues {
    @Entry var luminareCornerRadii: RectangleCornerRadii = .init(12)
    @Entry var luminareMinHeight: CGFloat = 30
    @Entry var luminareHorizontalPadding: CGFloat = 8

    @Entry var luminareBorderedStates: LuminareBorderedStates = .all
    @Entry var luminareFilledStates: LuminareFilledStates = .all
    @Entry var luminareHasDividers: Bool = true

    @Entry var luminareAspectRatio: CGFloat?
    @Entry var luminareAspectRatioContentMode: ContentMode? = .fit
    @Entry var luminareAspectRatioHasFixedHeight: Bool = true

    @Entry var luminareContentMarginsTop: CGFloat = 0
    @Entry var luminareContentMarginsLeading: CGFloat = 0
    @Entry var luminareContentMarginsBottom: CGFloat = 0
    @Entry var luminareContentMarginsTrailing: CGFloat = 0

    // MARK: Button

    @Entry var luminareButtonCornerRadii: RectangleCornerRadii = .init(2)
    @Entry var luminareButtonMaterial: Material? = nil

    @Entry var luminareCompactButtonCornerRadii: RectangleCornerRadii = .init(8)

    // MARK: Form

    @available(macOS 15.0, *)
    @Entry var luminareFormSpacing: CGFloat = 15

    // MARK: Pane

    @Entry var luminarePaneLayout: LuminarePaneLayout = .stacked
    // A naming convention: `titleBar` for SwiftUI, `titlebar` for AppKit, and `title bar` for natural language
    @Entry var luminareTitleBarHeight: CGFloat = 50

    // MARK: Section

    @Entry var luminareSectionLayout: LuminareSectionLayout = .stacked

    // If 0, then luminareSection will be of fixed size.
    @Entry var luminareSectionMaxWidth: CGFloat? = .infinity

    // MARK: Compose

    @Entry var luminareComposeControlSize: LuminareComposeControlSize = .automatic
    @Entry var luminareComposeStyle: LuminareComposeStyle = .regular

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

    @Entry var luminareListItemCornerRadii: RectangleCornerRadii = .init(2)

    @Entry var luminareListItemHeight: CGFloat = 50
    @Entry var luminareListItemHighlightOnHover: Bool = true
    @Entry var luminareItemBeingHovered: Bool = false
    @Entry var luminareListFixedHeightUntil: CGFloat? = nil

    @Entry var luminareListRoundedTopCornerBehavior: LuminareListRoundedCornerBehavior = .never
    @Entry var luminareListRoundedBottomCornerBehavior: LuminareListRoundedCornerBehavior = .never

    // MARK: Picker

    @Entry var luminarePickerRoundedTopCornerBehavior: LuminarePickerRoundedCornerBehavior = .never
    @Entry var luminarePickerRoundedBottomCornerBehavior: LuminarePickerRoundedCornerBehavior = .never

    // MARK: Sidebar

    @Entry var luminareSidebarOverflow: CGFloat = 50

    // MARK: Slider

    @Entry var luminareSliderLayout: LuminareSliderLayout = .regular

    // MARK: Slider Picker

    @Entry var luminareSliderPickerLayout: LuminareSliderPickerLayout = .regular
}
