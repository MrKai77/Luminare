//
//  LuminareTabItem.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A tab item for ``LuminareSidebarTab``.
///
/// ## Topics
///
/// ### Related Views
///
/// - ``LuminareSidebar``
/// - ``LuminareSidebarTab``
public protocol LuminareTabItem: Equatable, Hashable, Identifiable where ID: Identifiable {
    /// The unique id of the tab.
    var id: ID { get }

    /// The title of the tab.
    var title: String { get }
    /// The ``Image`` that will be displayed next to the leading edge of the ``title``.
    var icon: Image { get }
    /// Whether this tab displays an indicator at the trailing top edge of the title.
    /// This is typically used to attract user's attention to some updates.
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
