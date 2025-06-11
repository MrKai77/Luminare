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
            HStack(spacing: 8) {
                imageView(for: tab)

                titleView(for: tab)
                    .fixedSize()

                Spacer(minLength: 0)
            }
            .frame(minHeight: minHeight)
        }
        .buttonStyle(SidebarButtonStyle(isActive: $isActive))
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.quaternary, lineWidth: 1)
            }
        }
        .onAppear {
            processActiveTab()
        }
        .onChange(of: activeTab) { _ in
            processActiveTab()
        }
    }

    @ViewBuilder private func titleView(for tab: Tab) -> some View {
        HStack(spacing: 0) {
            Text(tab.title)

            if tab.hasIndicator {
                VStack {
                    Circle()
                        .foregroundStyle(.tint)
                        .frame(width: 4, height: 4)
                        .padding(.leading, 4)
                        .shadow(color: tintColor, radius: 4)

                    Spacer()
                }
                .transition(.opacity.animation(animation))
            }
        }
    }

    @ViewBuilder private func imageView(for tab: Tab) -> some View {
        tab.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(8)
            .frame(width: minHeight, height: minHeight)
            .background(.quinary)
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.quaternary, lineWidth: 1)
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
            .animation(animationFast, value: isHovering)
            .animation(animationFast, value: isActive)
            .animation(animationFast, value: configuration.isPressed)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onHover { isHovering in
                self.isHovering = isHovering
            }
    }
}

// MARK: - Preview

private enum Tab: LuminareTabItem, CaseIterable, Identifiable {
    case about

    var id: Self { self }

    var title: String {
        switch self {
        case .about: .init(localized: "About")
        }
    }

    var image: Image {
        switch self {
        case .about: .init(systemName: "app.gift")
        }
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareSidebarTab",
    traits: .sizeThatFitsLayout
) {
    LuminareSidebarTab(Tab.about, .constant(Tab.about))
        .frame(width: 225)
}
