//
//  Alignment+Extensions.swift
//  Luminare
//
//  Created by Kai Azim on 2025-03-08.
//

import SwiftUI

extension Alignment {
    var negate: Self {
        switch self {
        case .top: .bottom
        case .leading: .trailing
        case .bottom: .top
        case .trailing: .leading
        case .topLeading: .bottomTrailing
        case .topTrailing: .bottomLeading
        case .bottomLeading: .topTrailing
        case .bottomTrailing: .topLeading
        case .center: .center
        default: .center
        }
    }
}
