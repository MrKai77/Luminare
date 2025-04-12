//
//  Array+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/11/4.
//

import SwiftUI

extension Array {
    func slice(size: Int) -> [[Element]] {
        (0 ..< (count / size + (count % size == 0 ? 0 : 1)))
            .map {
                Array(self[($0 * size) ..< (Swift.min($0 * size + size, count))])
            }
    }
}
