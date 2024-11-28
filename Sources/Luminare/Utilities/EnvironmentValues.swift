//
//  EnvironmentValues.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - Luminare

public extension EnvironmentValues {
    // MARK: - General
    
    // currently, it is impossible to read the `.tint()` modifier on a view
    // this is a custom environement value as an alternative implementation of it
    // in practice, it should always be synchronized with `.tint()`
    @Entry var luminareTint: () -> Color = { .accentColor }
    
    @Entry var luminareAnimation: Animation = .smooth(duration: 0.2)
    @Entry var luminareAnimationFast: Animation = .easeInOut(duration: 0.1)
    
    // MARK: - Auxiliary
    
    @Entry var hoveringOverLuminareItem: Bool = false
    
    // MARK: - Window
    
    @Entry var luminareWindow: NSWindow?
    @Entry var clickedOutsideFlag: Bool = false
}
