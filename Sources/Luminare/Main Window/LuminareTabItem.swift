//
//  LuminareTabItem.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public protocol LuminareTabItem: Equatable, Hashable, Identifiable where ID: Identifiable {
    var id: ID { get }

    var title: String { get }
    var icon: Image { get }
    var hasIndicator: Bool { get }
}

public extension LuminareTabItem {
    var hasIndicator: Bool { false }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }

    @ViewBuilder
    func iconView() -> some View {
        Color.clear
            .overlay {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(10)
            .fixedSize()
            .background(.quinary)
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
    }
}
