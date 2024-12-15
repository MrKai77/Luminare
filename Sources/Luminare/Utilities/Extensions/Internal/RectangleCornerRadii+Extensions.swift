//
//  RectangleCornerRadii+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/15.
//

import SwiftUI

extension RectangleCornerRadii {
    func map(_ transform: @escaping (CGFloat) -> CGFloat) -> Self {
        .init(
            topLeading: transform(topLeading),
            bottomLeading: transform(bottomLeading),
            bottomTrailing: transform(bottomTrailing),
            topTrailing: transform(topTrailing)
        )
    }
}
