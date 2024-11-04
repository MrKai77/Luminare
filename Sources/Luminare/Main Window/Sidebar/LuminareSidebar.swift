//
//  LuminareSidebar.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized sidebar for ``LuminareWindow``.
///
/// Typically, the content is consisted of multiple ``LuminareSidebarTab`` organized by ``LuminareSidebarSection``:
///
/// ```swift
/// LuminareSidebar {
///     LuminareSidebarSection("Application", selection: $selection, items: [...])
///     LuminareSidebarSection("About", selection: $selection, items: [...])
///     ...
/// }
/// ```
///
/// ### Inadequacies
///
/// This view isn't currently scrollable, so please be aware of the content height.
///
/// ## Topics
///
/// ### Related Views
///
/// - ``LuminareWindow``
/// - ``LuminareSidebarSection``
/// - ``LuminareSidebarTab``
public struct LuminareSidebar<Content>: View where Content: View {
    @ViewBuilder private let content: () -> Content

    /// Initializes a ``LuminareSidebar``.
    ///
    /// - Parameter content: the sidebar content. Typically multiple ``LuminareSidebarTab`` organized by ``LuminareSidebarSection``.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 24) {
            content()
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 580, maxHeight: .infinity, alignment: .top)
        .luminareBackground()
    }
}
