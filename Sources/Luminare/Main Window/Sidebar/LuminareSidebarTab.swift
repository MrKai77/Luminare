//
//  LuminareSidebarTab.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

// MARK: - Sidebar Tab

/// A stylized tab for ``LuminareSidebar`` that is designed to be selectable.
public struct LuminareSidebarTab<Tab>: View where Tab: LuminareTabItem {
    // MARK: Environments

    @Environment(\.luminareMinHeight) private var minHeight
    @Environment(\.luminareTintColor) private var tintColor
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    // MARK: Fields

    @Binding private var activeTab: Tab?
    private let tab: Tab

    @State private var isActive = false

    // MARK: Initializers

    /// Initializes a ``LuminareSidebarTab``.
    ///
    /// - Parameters:
    ///   - tab: the associated ``LuminareTabItem``.
    ///   - activeTab: the activated ``LuminareTabItem`` binding.
    public init(_ tab: Tab, _ activeTab: Binding<Tab?>) {
        self._activeTab = activeTab
        self.tab = tab
    }

    // MARK: Body

    public var body: some View {
        Button {
            activeTab = tab
        } label: {
            titleView(for: tab)
                .fixedSize()
                .frame(
                    maxWidth: .infinity,
                    minHeight: minHeight,
                    alignment: .leading
                )
        }
        .buttonStyle(SidebarButtonStyle(isActive: isActive))
        .onAppear {
            processActiveTab()
        }
        .onChange(of: activeTab) { _ in
            processActiveTab()
        }
    }

    private func titleView(for tab: Tab) -> some View {
        HStack(spacing: 4) {
            tab.icon
                .frame(width: minHeight, height: minHeight)

            Text(tab.title)

            if tab.hasIndicator {
                VStack {
                    Circle()
                        .foregroundStyle(.tint)
                        .frame(width: 4, height: 4)
                        .shadow(color: tintColor, radius: 4)

                    Spacer()
                }
                .transition(.opacity.animation(animation))
            }
        }
    }

    // MARK: Functions

    private func processActiveTab() {
        withAnimation(animationFast) {
            isActive = activeTab == tab
        }
    }
}

// MARK: - Button Style (Sidebar)

struct SidebarButtonStyle: ButtonStyle {
    @Environment(\.luminareAnimationFast) private var animationFast

    let cornerRadius: CGFloat = 12
    @State var isHovering: Bool = false
    let isActive: Bool

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
            .animation(animationFast, value: isActive)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .contentShape(.rect)
            .onHover { isHovering = $0 }
    }
}

// MARK: - Preview

private enum Tab: LuminareTabItem, CaseIterable, Identifiable {
    case about
    case more

    var id: Self { self }

    var icon: some View {
        image
    }

    var title: String {
        switch self {
        case .about: .init(localized: "About")
        case .more: .init(localized: "More")
        }
    }

    var image: Image {
        switch self {
        case .about: .init(systemName: "app.gift")
        case .more: .init(systemName: "arrow.2.circlepath.circle")
        }
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareSidebarTab",
    traits: .sizeThatFitsLayout
) {
    VStack(spacing: 4) {
        LuminareSidebarTab(Tab.about, .constant(Tab.about))
        LuminareSidebarTab(Tab.more, .constant(Tab.about))
    }
    .frame(width: 225)
    .padding(4)
}
