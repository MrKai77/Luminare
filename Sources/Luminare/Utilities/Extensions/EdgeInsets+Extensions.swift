//
//  EdgeInsets+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/19.
//

import SwiftUI

public extension EdgeInsets {
    static var zero: Self { .init(0) }

    init(_ length: CGFloat) {
        self.init(
            top: length,
            leading: length,
            bottom: length,
            trailing: length
        )
    }

    init(_ edges: Edge.Set, _ length: CGFloat) {
        self.init(
            top: edges.contains(.top) ? length : 0,
            leading: edges.contains(.leading) ? length : 0,
            bottom: edges.contains(.bottom) ? length : 0,
            trailing: edges.contains(.trailing) ? length : 0
        )
    }
}

extension EdgeInsets {
    func map(_ transform: @escaping (CGFloat) -> CGFloat) -> Self {
        .init(
            top: transform(top),
            leading: transform(leading),
            bottom: transform(bottom),
            trailing: transform(trailing)
        )
    }
}
