//
//  EnvironmentValues.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - TintColor (Private)

// currently, it is impossible to read the `.tint(Color)` modifier on a view
// this is a custom environement value as an alternative implementation of it
public struct TintColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: () -> Color = { .accentColor }
}

public extension EnvironmentValues {
    var tintColor: () -> Color {
        get { self[TintColorEnvironmentKey.self] }
        set { self[TintColorEnvironmentKey.self] = newValue }
    }
}

// MARK: - HoveringOverLuminareItem

public struct HoveringOverLuminareItemEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var hoveringOverLuminareItem: Bool {
        get { self[HoveringOverLuminareItemEnvironmentKey.self] }
        set { self[HoveringOverLuminareItemEnvironmentKey.self] = newValue }
    }
}

// MARK: - LuminareWindow

public struct LuminareWindowEnvironmentKey: EnvironmentKey {
    public static let defaultValue: NSWindow? = nil
}

public extension EnvironmentValues {
    var luminareWindow: NSWindow? {
        get { self[LuminareWindowEnvironmentKey.self] }
        set { self[LuminareWindowEnvironmentKey.self] = newValue }
    }
}

// MARK: - ClickedOutside (Private)

struct ClickedOutsideFlagEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var clickedOutsideFlag: Bool {
        get { self[ClickedOutsideFlagEnvironmentKey.self] }
        set { self[ClickedOutsideFlagEnvironmentKey.self] = newValue }
    }
}
