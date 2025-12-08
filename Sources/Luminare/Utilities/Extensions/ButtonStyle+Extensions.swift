//
//  ButtonStyle+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

public extension ButtonStyle where Self == LuminarePlateauButtonStyle {
    static var luminare: Self { .init() }
    static func luminare(tinted _: Bool = false) -> Self { .init() }
}
