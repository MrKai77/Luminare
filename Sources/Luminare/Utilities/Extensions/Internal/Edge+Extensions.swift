//
//  Edge+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/8.
//

import SwiftUI

extension Edge {
    var negate: Self {
        switch self {
        case .top: .bottom
        case .leading: .trailing
        case .bottom: .top
        case .trailing: .leading
        }
    }

    var alignment: Alignment {
        switch self {
        case .top: .top
        case .leading: .leading
        case .bottom: .bottom
        case .trailing: .trailing
        }
    }
}
