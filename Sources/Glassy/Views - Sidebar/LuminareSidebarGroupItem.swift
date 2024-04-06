//
//  LuminareSidebarGroupItem.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct LuminareSidebarGroupItem: View {
    @Binding var activeTab: SettingsTab
    let tab: SettingsTab

    @State private var isHovering: Bool = false
    @State private var isActive: Bool = false

    init(_ tab: SettingsTab, _ activeTab: Binding<SettingsTab>) {
        self._activeTab = activeTab
        self.tab = tab
    }

    var body: some View {
        Button {
            activeTab = self.tab
        } label: {
            HStack {
                self.tab.iconView()
                Text(tab.title)

                Spacer()
            }
            .padding(5)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.quaternary, lineWidth: 1).opacity((self.isActive) ? 1 : 0)
                    .background(.quinary.opacity((self.isHovering || self.isActive) ? 0.9 : 0))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            checkIfSelfIsActiveTab()
        }
        .onChange(of: self.activeTab) { _ in
            checkIfSelfIsActiveTab()
        }
        .onHover { hovering in
            self.isHovering = hovering
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    func checkIfSelfIsActiveTab() {
        withAnimation(.easeOut(duration: 0.1)) {
            self.isActive = self.activeTab == self.tab
        }
    }
}
