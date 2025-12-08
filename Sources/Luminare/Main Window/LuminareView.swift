//
//  LuminareView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-10-06.
//

import SwiftUI

// MARK: - Luminare View

/// The root view of a ``LuminareWindow``.
///
/// This view automatically overrides the content's tint by the one specified with the `luminareTintColor` environment value.
public struct LuminareView<Content>: View where Content: View {
    // MARK: Environments

    @Environment(\.luminareTintColor) private var tintColor

    // MARK: Fields

    @ViewBuilder public let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        content()
            .focusable(false)
            .buttonStyle(.luminare)
            .luminareTint(overridingWith: tintColor)
    }
}
