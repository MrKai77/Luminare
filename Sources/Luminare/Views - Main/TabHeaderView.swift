//
//  TabHeaderView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct TabHeaderView: View {
    @EnvironmentObject var settingsWindow: LuminareSettingsWindow
    @Binding var activeTab: SettingsTab

    init(_ activeTab: Binding<SettingsTab>) {
        self._activeTab = activeTab
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack {
                activeTab.iconView()

                Text(activeTab.title)
                    .font(.title2)

                Spacer()

                Group {
                    if settingsWindow.showPreview {
                        settingsWindow.hidePreviewIcon
                    } else {
                        settingsWindow.showPreviewIcon
                    }
                }
                .foregroundStyle(.secondary)
                .animation(.smooth(duration: 0.25), value: settingsWindow.showPreview)
            }
            .padding(.horizontal, 10)
            .padding(.trailing, 5)

            Spacer()
        }
        .frame(height: 50)
    }
}
