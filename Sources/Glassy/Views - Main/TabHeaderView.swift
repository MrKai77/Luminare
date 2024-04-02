//
//  TabHeaderView.swift
//  
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct TabHeaderView<Content: View>: View {
    @Binding var activeTab: SettingsTab<Content>

    init(_ activeTab: Binding<SettingsTab<Content>>) {
        self._activeTab = activeTab
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack {
                self.activeTab.iconView()

                Text(self.activeTab.title)
                    .font(.title2)

                Spacer()
            }
            .padding(.horizontal, 10)

            Spacer()

            sectionDivider()
        }
        .frame(height: 50 + 1) // one for the divider
    }

    @ViewBuilder func sectionDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(.primary.opacity(0.1))
    }
}
