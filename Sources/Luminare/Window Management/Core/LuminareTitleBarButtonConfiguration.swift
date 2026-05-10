//
//  LuminareTitleBarButtonConfiguration.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-10.
//

import Foundation

public struct LuminareTitleBarButtonConfiguration: Sendable {
    public static let `default` = Self(padding: 18.5, spacing: 0)

    public let padding: CGFloat
    public let spacing: CGFloat

    public init(padding: CGFloat, spacing: CGFloat) {
        self.padding = padding
        self.spacing = spacing
    }
}
