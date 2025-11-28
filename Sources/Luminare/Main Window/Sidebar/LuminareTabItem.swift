//
//  LuminareTabItem.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// The content of a ``LuminareSidebarTab``.
///
/// It's convenient to implement your own tab instances:
///
/// ```swift
/// enum Tab: LuminareTabItem, CaseIterable, Identifiable {
///     case general
///     case about
///
///     var id: Self { self }
///
///     var title: String {
///         switch self {
///         case .general: .init(localized: "General")
///         case .about: .init(localized: "About")
///         }
///     }
///
///     var image: Image {
///         switch self {
///         case .general: .init(systemName: "gear")
///         case .about: .init(systemName: "app.gift")
///         }
///     }
/// }
/// ```
public protocol LuminareTabItem: Equatable, Hashable, Identifiable {
    /// The title of the tab.
    var title: String { get }

    /// The `Image` that will be displayed next to the leading edge of the ``title``.
    var image: Image { get }

    /// Whether this tab displays an indicator at the trailing top edge of the title.
    /// Typically used to attract users' attention.
    var hasIndicator: Bool { get }
}

public extension LuminareTabItem {
    var hasIndicator: Bool { false }

    @MainActor
    var decoratedImageView: some View {
        DecoratedImageView(tab: self)
    }
}

// MARK: Image View

private struct DecoratedImageView<Tab>: View where Tab: LuminareTabItem {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.luminareMinHeight) private var minHeight

    private var imageSize: CGFloat {
        boxSize - 10
    }

    private var boxSize: CGFloat {
        minHeight - 4
    }

    let tab: Tab

    var body: some View {
        Group {
            tab.image
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
        .frame(width: boxSize, height: boxSize)
        .modifier(LuminarePlateauModifier())
        .frame(width: minHeight, height: minHeight)
        .luminareCornerRadius(6)
    }
}
