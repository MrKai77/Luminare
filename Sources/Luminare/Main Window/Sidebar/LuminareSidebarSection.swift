//
//  LuminareSidebarSection.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

// MARK: - Sidebar Section

public struct LuminareSidebarSection<Label, Tab>: View where Label: View, Tab: LuminareTabItem, Tab: Hashable {
    // MARK: Fields
    
    @Binding private var selection: Tab
    private let items: [Tab]
    
    @ViewBuilder private let label: () -> Label

    // MARK: Initializers

    public init(
        selection: Binding<Tab>,
        items: [Tab],
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._selection = selection
        self.items = items
        self.label = label
    }
    
    public init(
        _ key: LocalizedStringKey,
        selection: Binding<Tab>,
        items: [Tab]
    ) where Label == Text {
        self.init(
            selection: selection,
            items: items
        ) {
            Text(key)
        }
    }
    
    // MARK: Body

    public var body: some View {
        VStack {
            if Label.self != EmptyView.self {
                HStack {
                    label()
                        .opacity(0.7)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                    Spacer()
                }
            }

            ForEach(items) { item in
                LuminareSidebarTab(item, $selection)
            }
        }
    }
}
