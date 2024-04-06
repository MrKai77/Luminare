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
        }
        .buttonStyle(SidebarButtonStyle(isActive: $isActive))
        .overlay {
            if self.isActive {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
        }
        .onAppear {
            checkIfSelfIsActiveTab()
        }
        .onChange(of: self.activeTab) { _ in
            checkIfSelfIsActiveTab()
        }
    }

    func checkIfSelfIsActiveTab() {
        withAnimation(.easeOut(duration: 0.1)) {
            self.isActive = self.activeTab == self.tab
        }
    }
}

struct SidebarButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat = 12
    @State var isHovering: Bool = false
    @Binding var isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)

            .background {
                if configuration.isPressed{
                    Rectangle().foregroundStyle(.quaternary)
                } else if isHovering || self.isActive {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                }
            }

            .onHover { hover in
                self.isHovering = hover
            }
            .animation(.easeOut(duration: 0.1), value: [self.isHovering, self.isActive, configuration.isPressed])

            .clipShape(.rect(cornerRadius: cornerRadius))

            .onChange(of: self.isActive) { _ in
                print(self.isActive)
            }
    }
}
