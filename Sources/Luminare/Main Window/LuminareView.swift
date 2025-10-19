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
    @Environment(\.luminareWindow) private var window

    // MARK: Fields

    @ViewBuilder public let content: () -> Content
    @State private var contentSize: CGSize = .zero

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        content()
            .focusable(false)
            .buttonStyle(.luminare)
            .luminareTint(overridingWith: tintColor)
            .background {
                Color.clear
                    .onGeometryChange(for: CGSize.self, of: \.size) {
                        contentSize = $0
                    }
                    .onAppear {
                        window?.setSize(size: contentSize, animate: false)
                        window?.center()
                    }
                    .onChange(of: contentSize) {
                        window?.setSize(size: $0, animate: true)
                    }
                    .ignoresSafeArea()
            }
            .frame(minWidth: 10, maxWidth: .infinity, minHeight: 10, maxHeight: .infinity, alignment: .leading)
    }
}
