//
//  Comparable+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/11/4.
//

import SwiftUI

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
