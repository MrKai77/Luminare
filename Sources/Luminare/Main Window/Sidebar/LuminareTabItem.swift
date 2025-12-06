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
    associatedtype Content: View

    /// The title of the tab.
    var title: String { get }
    
    /// The icon for the tab.
    var icon: Content { get }

    /// Whether this tab displays an indicator at the trailing top edge of the title.
    /// Typically used to attract users' attention.
    var hasIndicator: Bool { get }
}

public extension LuminareTabItem {
    var hasIndicator: Bool { false }
}
