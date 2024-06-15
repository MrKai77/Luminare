//
//  EnvironmentValues.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - TintColor (public)

// Currently, it is impossible to read the .tint(Color) modifier on a view.
// This is a custom environement value as an alternative implementation of it.
public struct TintColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: () -> Color = { .accentColor }
}

public extension EnvironmentValues {
    var tintColor: () -> Color {
        get { self[TintColorEnvironmentKey.self] }
        set { self[TintColorEnvironmentKey.self] = newValue }
    }
}

// MARK: - HoveringOverLuminareItem (public)

public struct HoveringOverLuminareItem: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var hoveringOverLuminareItem: Bool {
        get { self[HoveringOverLuminareItem.self] }
        set { self[HoveringOverLuminareItem.self] = newValue }
    }
}

// MARK: - FloatingPanel

struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSWindow? = nil
}

extension EnvironmentValues {
    var floatingPanel: NSWindow? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}

// MARK: - ClickedOutside

struct ClickedOutsideFlagKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var clickedOutsideFlag: Bool {
        get { self[ClickedOutsideFlagKey.self] }
        set { self[ClickedOutsideFlagKey.self] = newValue }
    }
}

// MARK: - CurrentlyScrolling

struct CurrentlyScrollingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var currentlyScrolling: Bool {
        get { self[CurrentlyScrollingKey.self] }
        set { self[CurrentlyScrollingKey.self] = newValue }
    }
}
