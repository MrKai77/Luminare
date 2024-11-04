//
//  EnvironmentValues.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - Luminare

// MARK: LuminareTint

// currently, it is impossible to read the `.tint(Color)` modifier on a view
// this is a custom environement value as an alternative implementation of it
public struct LuminareTintEnvironmentKey: EnvironmentKey {
    public static var defaultValue: () -> Color = { .accentColor }
}

public extension EnvironmentValues {
    var luminareTint: () -> Color {
        get { self[LuminareTintEnvironmentKey.self] }
        set { self[LuminareTintEnvironmentKey.self] = newValue }
    }
}

// MARK: LuminareAnimation

public struct LuminareAnimationEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Animation = .smooth(duration: 0.2)
}

public extension EnvironmentValues {
    var luminareAnimation: Animation {
        get { self[LuminareAnimationEnvironmentKey.self] }
        set { self[LuminareAnimationEnvironmentKey.self] = newValue }
    }
}

// MARK: LuminareAnimationFast

public struct LuminareAnimationFastEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Animation = .easeInOut(duration: 0.1)
}

public extension EnvironmentValues {
    var luminareAnimationFast: Animation {
        get { self[LuminareAnimationFastEnvironmentKey.self] }
        set { self[LuminareAnimationFastEnvironmentKey.self] = newValue }
    }
}

// MARK: - Luminare Auxiliary

// MARK: HoveringOverLuminareItem

public struct HoveringOverLuminareItemEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var hoveringOverLuminareItem: Bool {
        get { self[HoveringOverLuminareItemEnvironmentKey.self] }
        set { self[HoveringOverLuminareItemEnvironmentKey.self] = newValue }
    }
}

// MARK: - Luminare Window

// MARK: LuminareWindow

public struct LuminareWindowEnvironmentKey: EnvironmentKey {
    public static let defaultValue: NSWindow? = nil
}

public extension EnvironmentValues {
    var luminareWindow: NSWindow? {
        get { self[LuminareWindowEnvironmentKey.self] }
        set { self[LuminareWindowEnvironmentKey.self] = newValue }
    }
}

// MARK: ClickedOutside (Private)

struct ClickedOutsideFlagEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var clickedOutsideFlag: Bool {
        get { self[ClickedOutsideFlagEnvironmentKey.self] }
        set { self[ClickedOutsideFlagEnvironmentKey.self] = newValue }
    }
}
