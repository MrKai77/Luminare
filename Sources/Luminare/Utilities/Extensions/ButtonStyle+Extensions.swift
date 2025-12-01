//
//  ButtonStyle+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

// MARK: - LuminareButtonStyle

public extension ButtonStyle where Self == LuminarePlateauButtonStyle {
    static var luminare: Self { .init() }
    static func luminare(tinted _: Bool = false) -> Self { .init() }
}

// MARK: - LuminareCosmeticButtonStyle

public extension ButtonStyle where Self == LuminareCosmeticButtonStyle {
    static func luminareCosmetic(icon: Image) -> Self { .init(icon: icon) }
}
