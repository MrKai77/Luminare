//
//  RectangleCornerRadii+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/14.
//

import SwiftUI

extension RectangleCornerRadii {
    static var zero: Self { .init(0) }

    init(_ radius: CGFloat) {
        self.init(
            topLeading: radius,
            bottomLeading: radius,
            bottomTrailing: radius,
            topTrailing: radius
        )
    }

    func map(_ transform: @escaping (CGFloat) -> CGFloat) -> Self {
        .init(
            topLeading: transform(topLeading),
            bottomLeading: transform(bottomLeading),
            bottomTrailing: transform(bottomTrailing),
            topTrailing: transform(topTrailing)
        )
    }
}
