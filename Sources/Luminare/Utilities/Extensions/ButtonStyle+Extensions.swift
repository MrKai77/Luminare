//
//  ButtonStyle+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

public extension ButtonStyle where Self == LuminarePlateauButtonStyle {
    static var luminare: Self { .init() }
    static func luminare(
        tinted: Bool = false,
        overrideIsHovering: Bool = false
    ) -> Self {
        LuminarePlateauButtonStyle(
            tinted: tinted,
            overrideIsHovering: overrideIsHovering
        )
    }
}
