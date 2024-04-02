//
//  GlassySidebarView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct GlassySidebarView<Content>: View where Content: View {
    let titlebarHeight: CGFloat = 50
    let groupSpacing: CGFloat = 24
    let itemPadding: CGFloat = 12
    let groupTitlePadding: CGFloat = 8
    let itemSpacing: CGFloat = 4

    @Binding var activeTab: SettingsTab<Content>
    let groups: [SettingsTabGroup<Content>]

    init(_ groups: [SettingsTabGroup<Content>], _ activeTab: Binding<SettingsTab<Content>>) {
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
                        GlassySidebarGroupItem(tab, $activeTab)
                    }
                }
            }
            .padding(.bottom, groupSpacing)

            Spacer()
        }
        .padding(.horizontal, itemPadding)
    }

    @ViewBuilder func groupTitle(_ group: SettingsTabGroup<Content>) -> some View {
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
