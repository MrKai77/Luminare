//
//  LuminareSidebarView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct LuminareSidebarView: View {
    let titlebarHeight: CGFloat = 50
    let groupSpacing: CGFloat = 24
    let itemPadding: CGFloat = 12
    let groupTitlePadding: CGFloat = 4
    let itemSpacing: CGFloat = 4

    @Binding var activeTab: SettingsTab
    let groups: [SettingsTabGroup]

    init(_ groups: [SettingsTabGroup], _ activeTab: Binding<SettingsTab>) {
        self._activeTab = activeTab
        self.groups = groups
    }

    var body: some View {
        VStack {
            Spacer()
                .frame(height: titlebarHeight)

            ForEach(self.groups) { group in
                VStack(spacing: itemSpacing) {
                    groupTitle(group)

                    ForEach(group.tabs) { tab in
                        LuminareSidebarGroupItem(tab, $activeTab)
                    }
                }
            }
            .padding(.bottom, groupSpacing)

            Spacer()
        }
        .padding(.horizontal, itemPadding)
    }

    @ViewBuilder func groupTitle(_ group: SettingsTabGroup) -> some View {
        if let title = group.title {
            HStack {
                Text(title)
                    .opacity(0.7)
                    .fontWeight(.medium)
                    .padding(.leading, groupTitlePadding)
                Spacer()
            }
        }
    }
}
