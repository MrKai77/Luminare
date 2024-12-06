//
//  EnvironmentValues.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - Commons

public extension EnvironmentValues {
    // MARK: General

    // currently, it is impossible to read the `.tint()` modifier on a view
    // this is a custom environement value as an alternative implementation of it
    // in practice, it should always be synchronized with `.tint()`
    @Entry var luminareTint: () -> Color = { .accentColor }

    @Entry var luminareAnimation: Animation = .smooth(duration: 0.2)
    @Entry var luminareAnimationFast: Animation = .easeInOut(duration: 0.1)

    // MARK: Auxiliary

    @Entry var hoveringOverLuminareItem: Bool = false

    // MARK: Window

    @Entry var luminareWindow: NSWindow?
    @Entry var luminareClickedOutside: Bool = false
}

// MARK: - Initializers

public extension EnvironmentValues {
    // MARK: General

    @Entry var luminareCornerRadius: CGFloat = 12
    @Entry var luminareMinHeight: CGFloat = 34
    @Entry var luminareHorizontalPadding: CGFloat = 8
    @Entry var luminareIsBordered: Bool = true
    @Entry var luminareHasDividers: Bool = true

    // MARK: Luminare Button Style

    @Entry var luminareButtonMaterial: Material? = nil
    @Entry var luminareButtonCornerRadius: CGFloat = 2
    @Entry var luminareCompactButtonCornerRadius: CGFloat = 8
    @Entry var luminareButtonHighlightOnHover: Bool = true

    // MARK: Luminare Section

    @Entry var luminareSectionMaterial: Material? = nil
    @Entry var luminareSectionMaxWidth: CGFloat? = .infinity
    @Entry var luminareSectionIsMasked: Bool = false

    // MARK: Luminare Compose

    @Entry var luminareComposeControlSize: LuminareComposeControlSize = .regular

    // MARK: Luminare Popover

    @Entry var luminarePopoverTrigger: LuminarePopoverTrigger = .hover
    @Entry var luminarePopoverShade: LuminarePopoverShade = .styled

    // MARK: Luminare Stepper

    @available(macOS 15.0, *)
    @Entry var luminareStepperAlignment: LuminareStepperAlignment = .trailing
    @available(macOS 15.0, *)
    @Entry var luminareStepperDirection: LuminareStepperDirection = .horizontal

    // MARK: Luminare Compact Picker

    @Entry var luminareCompactPickerStyle: LuminareCompactPickerStyle = .menu

    // MARK: Luminare List

    @Entry var luminareListContentMarginsTop: CGFloat = 0
    @Entry var luminareListContentMarginsBottom: CGFloat = 0
    @Entry var luminareListItemCornerRadius: CGFloat = 2
    @Entry var luminareListItemHeight: CGFloat = 50
    @Entry var luminareListItemHighlightOnHover: Bool = true
}
