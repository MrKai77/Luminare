//
//  ContentView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.tintColor) var tintColor

    let sidebarWidth: CGFloat = 260
    let mainViewWidth: CGFloat = 390
    let mainViewSectionOuterPadding: CGFloat = 12
    let previewViewWidth: CGFloat = 520
    let windowHeight: CGFloat = 600
    let sectionSpacing: CGFloat = 16

    @State var activeTab: SettingsTab
    let groups: [SettingsTabGroup]

    init(_ groups: [SettingsTabGroup]) {
        self.groups = groups
        self.activeTab = groups.first!.tabs.first!
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                LuminareSidebarView(groups, $activeTab)
                    .frame(width: sidebarWidth)

                Divider()

                DividedVStack(spacing: 0, applyMaskToItems: false) {
                    TabHeaderView($activeTab)

                    ScrollView {
                        VStack(spacing: sectionSpacing) {
                            self.activeTab.view
                        }
                        .padding(mainViewSectionOuterPadding)
                    }
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

        .buttonStyle(LuminareButtonStyle())

        .tint(self.tintColor)
    }
}
