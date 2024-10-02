//
//  LuminareSidebarSection.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminareSidebarSection<Tab>: View where Tab: LuminareTabItem, Tab: Hashable {
    let title: String?
    @Binding var selection: Tab
    let items: [Tab]

    public init(_ title: String? = nil, selection: Binding<Tab>, items: [Tab]) {
        self.title = title
        self._selection = selection
        self.items = items
    }

    public var body: some View {
        VStack {
            sectionTitle()

            ForEach(items) { item in
                LuminareSidebarTab(item, $selection)
            }
        }
    }

    @ViewBuilder func sectionTitle() -> some View {
        if let title = title {
            HStack {
                Text(title)
                    .opacity(0.7)
                    .fontWeight(.medium)
                    .padding(.leading, 4)
                Spacer()
            }
        }
    }
}
