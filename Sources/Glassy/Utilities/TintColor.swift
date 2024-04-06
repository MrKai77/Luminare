//
//  TintColor.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// Currently, it is impossible to read the .tint(Color) modifier on a view.
// This is a custom environement value as an alternative implementation of it.
public struct TintColorEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Color = .accentColor
}

public extension EnvironmentValues {
    var tintColor: Color {
        get { return self[TintColorEnvironmentKey.self] }
        set { self[TintColorEnvironmentKey.self] = newValue }
    }
}
