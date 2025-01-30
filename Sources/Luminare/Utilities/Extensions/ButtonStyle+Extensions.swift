//
//  ButtonStyle+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

// MARK: - LuminareButtonStyle

public extension ButtonStyle where Self == LuminareButtonStyle {
    static var luminare: Self { .init() }
}

// MARK: - LuminareProminentButtonStyle

public extension ButtonStyle where Self == LuminareProminentButtonStyle {
    static var luminareProminent: Self { .init() }
}

// MARK: - LuminareCosmeticButtonStyle

public extension ButtonStyle where Self == LuminareCosmeticButtonStyle {
    static func luminareCosmetic(_ icon: @escaping () -> Image) -> Self { .init(icon: icon) }
}

// MARK: - LuminareCompactButtonStyle

public extension ButtonStyle where Self == LuminareCompactButtonStyle {
    static var luminareCompact: Self { .init() }
}
