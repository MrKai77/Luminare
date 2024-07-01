//
//  LuminareSidebarGroupItem.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct LuminareSidebarGroupItem: View {
    @Environment(\.tintColor) var tintColor

    @Binding var activeTab: SettingsTab
    let tab: SettingsTab

    @State private var isHovering: Bool = false
    @State private var isActive: Bool = false
    let didTabChange: (SettingsTab) -> ()

    init(_ tab: SettingsTab, _ activeTab: Binding<SettingsTab>, didTabChange: @escaping (SettingsTab) -> ()) {
        self._activeTab = activeTab
        self.tab = tab
        self.didTabChange = didTabChange
    }

    var body: some View {
        Button {
            activeTab = tab
            didTabChange(tab)
        } label: {
            HStack(spacing: 8) {
                tab.iconView()

                HStack(spacing: 0) {
                    Text(tab.title)

                    if let showIndicator = tab.showIndicator, showIndicator() {
                        VStack {
                            Circle()
                                .foregroundStyle(tintColor())
                                .frame(width: 4, height: 4)
                                .padding(.leading, 4)

                            Spacer()
                        }
                    }
                }
                .fixedSize()

                Spacer()
            }
        }
        .buttonStyle(SidebarButtonStyle(isActive: $isActive))
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
        }
        .onAppear {
            checkIfSelfIsActiveTab()
        }
        .onChange(of: activeTab) { _ in
            checkIfSelfIsActiveTab()
        }
    }

    func checkIfSelfIsActiveTab() {
        withAnimation(LuminareSettingsWindow.fastAnimation) {
            isActive = activeTab == tab
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
                if configuration.isPressed {
                    Rectangle().foregroundStyle(.quaternary)
                } else if isHovering || isActive {
                    Rectangle().foregroundStyle(.quaternary.opacity(0.7))
                }
            }
            .onHover { hover in
                isHovering = hover
            }
            .animation(LuminareSettingsWindow.fastAnimation, value: [isHovering, isActive, configuration.isPressed])
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}
