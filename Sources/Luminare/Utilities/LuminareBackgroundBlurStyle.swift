//
//  LuminareBackgroundBlurStyle.swift
//  Luminare
//
//  Created by Adon Omeri on 2025-03-23.
//

import SwiftUI

/// Controls how `luminareBackground` and the window’s root view render their blur.
public enum LuminareBackgroundBlurStyle: Equatable, Sendable {
    /// Applies a regular window material to the window.
    ///  - Note: This type does not use private APIs and is stable.
    case regular
    /// Set a custom blur level for the window.
    /// - Warning: This type uses private APIs and may break in a future OS. Test on all macOS versions you are targeting.
    case custom(radius: CGFloat)
}
