//
//  GlassySection.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public struct GlassySection: View {
    let cornerRadius = 12
    let padding = 12

    public init() {}

    public var body: some View {
        Rectangle()
            .foregroundStyle(.quinary)
            .padding(12)
    }
}
