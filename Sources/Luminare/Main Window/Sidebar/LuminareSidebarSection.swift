//
//  LuminareSidebarSection.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

// MARK: - Sidebar Section

/// A stylized section for ``LuminareSidebar``.
public struct LuminareSidebarSection<Label, Tab>: View where Label: View, Tab: LuminareTabItem, Tab: Hashable {
    // MARK: Fields

    @Binding private var selection: Tab
    private let items: [Tab]

    @ViewBuilder private var label: () -> Label

    // MARK: Initializers

    /// Initializes a ``LuminareSidebarSection``.
    ///
    /// - Parameters:
    ///   - selection: the selected ``LuminareTabItem`` binding.
    ///   - items: the list of available ``LuminareTabItem``.
    ///   - label: the label that is located at the very top of the containing tabs.
    public init(
        selection: Binding<Tab>,
        items: [Tab],
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._selection = selection
        self.items = items
        self.label = label
    }

    /// Initializes a ``LuminareSidebarSection`` whose label is a localized text.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the label text.
    ///   - selection: the selected ``LuminareTabItem`` binding.
    ///   - items: the list of available ``LuminareTabItem``.
    public init(
        _ key: LocalizedStringKey,
        selection: Binding<Tab>,
        items: [Tab]
    ) where Label == Text {
        self.init(
            selection: selection,
            items: items
        ) {
            Text(key)
        }
    }

    /// Initializes a ``LuminareSidebarSection`` without a label.
    ///
    /// - Parameters:
    ///   - selection: the selected ``LuminareTabItem`` binding.
    ///   - items: the list of available ``LuminareTabItem``.
    public init(
        selection: Binding<Tab>,
        items: [Tab]
    ) where Label == EmptyView {
        self.init(
            selection: selection,
            items: items
        ) {
            EmptyView()
        }
    }

    // MARK: Body

    public var body: some View {
        VStack {
            if Label.self != EmptyView.self {
                HStack {
                    label()
                        .opacity(0.7)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                    Spacer()
                }
            }

            ForEach(items) { item in
                LuminareSidebarTab(item, $selection)
            }
        }
    }
}

// MARK: - Preview

private enum Tab: LuminareTabItem, CaseIterable, Identifiable {
    case lorem
    case ipsum
    case fundamental
    case advanced
    case expert
    case about

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .lorem: .init(localized: "Lorem")
        case .ipsum: .init(localized: "Ipsum")
        case .fundamental: .init(localized: "Fundamental")
        case .advanced: .init(localized: "Advanced")
        case .expert: .init(localized: "Expert")
        case .about: .init(localized: "About")
        }
    }

    var icon: Image {
        switch self {
        case .lorem: .init(systemName: "paragraphsign")
        case .ipsum: .init(systemName: "strikethrough")
        case .fundamental: .init(systemName: "apple.meditate")
        case .advanced: .init(systemName: "airplane.departure")
        case .expert: .init(systemName: "flag.checkered.2.crossed")
        case .about: .init(systemName: "app.gift")
        }
    }

    var hasIndicator: Bool {
        switch self {
        case .expert:
            true
        default:
            false
        }
    }

    @ViewBuilder func view() -> some View {
        EmptyView()
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareSidebarSection",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        VStack(spacing: 24) {
            LuminareSidebarSection(selection: .constant(Tab.about), items: [Tab.lorem, .ipsum])
            LuminareSidebarSection(
                "Settings Graph",
                selection: .constant(Tab.about), items: [Tab.fundamental, .advanced, .expert]
            )
            LuminareSidebarSection(
                "Application",
                selection: .constant(Tab.about), items: [Tab.about]
            )
        }
    }
    .frame(width: 225)
}
