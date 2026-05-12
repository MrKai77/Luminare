//
//  ButtonStyle+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

public extension ButtonStyle where Self == LuminareSurfaceButtonStyle {
    static var luminare: Self {
        .init()
    }

    static func luminare(
        tinted: Bool = false,
        overrideIsHovering: Bool = false,
        overrideIsPressed: Bool = false
    ) -> Self {
        LuminareSurfaceButtonStyle(
            tinted: tinted,
            overrideIsHovering: overrideIsHovering,
            overrideIsPressed: overrideIsPressed
        )
    }
}
