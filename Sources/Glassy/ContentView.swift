//
//  ContentView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct ContentView<Content>: View where Content: View {
    let sidebarWidth: CGFloat = 260
    let mainViewWidth: CGFloat = 390
    let previewViewWidth: CGFloat = 520
    let windowHeight: CGFloat = 600

    @State var activeTab: SettingsTab<Content>
    let groups: [SettingsTabGroup<Content>]

    init(_ groups: [SettingsTabGroup<Content>]) {
        self.groups = groups
        self.activeTab = groups.first!.tabs.first!
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                GlassySidebarView(groups, $activeTab)
                    .frame(width: sidebarWidth)

                Divider()

                ZStack {
                    VStack {
                        TabHeaderView($activeTab)
                        Spacer()
                    }
                    self.activeTab.view()
                }
                .frame(width: mainViewWidth)

                Divider()
            }
            .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))

            Spacer()
                .frame(width: previewViewWidth)
        }
        .ignoresSafeArea()
        .frame(height: windowHeight)
        .fixedSize()
    }
}
