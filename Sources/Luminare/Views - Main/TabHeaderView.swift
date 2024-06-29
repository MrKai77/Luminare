//
//  TabHeaderView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct TabHeaderView: View {
    @Binding var activeTab: SettingsTab
    @Binding var showPreview: Bool

    init(_ activeTab: Binding<SettingsTab>, _ showPreview: Binding<Bool>) {
        self._activeTab = activeTab
        self._showPreview = showPreview
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack {
                activeTab.iconView()

                Text(activeTab.title)
                    .font(.title2)

                Spacer()

                Button("TOGGLE") {
                    withAnimation(.smooth(duration: 0.25)) {
                        showPreview.toggle()
                    }
                }
                .buttonStyle(.plain)
                .contentShape(.rect)
            }
            .padding(.horizontal, 10)

            Spacer()
        }
        .frame(height: 50)
    }
}
