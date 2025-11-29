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
    static func luminare(tinted: Bool = false) -> Self { .init(tinted: tinted) }
}

// MARK: - LuminareCosmeticButtonStyle

public extension ButtonStyle where Self == LuminareCosmeticButtonStyle {
    static func luminareCosmetic(icon: Image) -> Self { .init(icon: icon) }
}

// MARK: - LuminareCompactButtonStyle

public extension ButtonStyle where Self == LuminareCompactButtonStyle {
    static var luminareCompact: Self { .init() }
}
