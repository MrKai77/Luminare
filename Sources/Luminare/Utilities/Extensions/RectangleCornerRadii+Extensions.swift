//
//  RectangleCornerRadii+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/14.
//

import SwiftUI

public struct RectangleCornerRadiiCorners: OptionSet, Sendable {
    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let topLeading: Self = .init(rawValue: 1 << 0)
    public static let bottomLeading: Self = .init(rawValue: 1 << 1)
    public static let bottomTrailing: Self = .init(rawValue: 1 << 2)
    public static let topTrailing: Self = .init(rawValue: 1 << 3)

    public static let all: Self = [.topLeading, .bottomLeading, .bottomTrailing, .topTrailing]
    public static let top: Self = [.topLeading, .topTrailing]
    public static let bottom: Self = [.bottomLeading, .bottomTrailing]
    public static let leading: Self = [.topLeading, .bottomLeading]
    public static let trailing: Self = [.topTrailing, .bottomTrailing]
}

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

    func inset(corners: RectangleCornerRadiiCorners = .all, by amount: CGFloat, minRadius: CGFloat = 0) -> Self {
        var newRadii = self

        if corners.contains(.topLeading) {
            newRadii.topLeading = max(topLeading - amount, minRadius)
        }

        if corners.contains(.bottomLeading) {
            newRadii.bottomLeading = max(bottomLeading - amount, minRadius)
        }

        if corners.contains(.bottomTrailing) {
            newRadii.bottomTrailing = max(bottomTrailing - amount, minRadius)
        }

        if corners.contains(.topTrailing) {
            newRadii.topTrailing = max(topTrailing - amount, minRadius)
        }

        return newRadii
    }
}
