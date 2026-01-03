//
//  LuminareSection+Initializers.swift
//  Luminare
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

public extension LuminareSection {
    /// Initializes a ``LuminareSection`` whose header and footer are texts.
    ///
    /// - Parameters:
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    @_disfavoredOverload
    init(
        _ header: some StringProtocol,
        _ footer: some StringProtocol,
        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == Text {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } header: {
            Text(header)
                .fontWeight(.medium)
        } footer: {
            Text(footer)
                .font(.caption)
        }
    }

    /// Initializes a ``LuminareSection`` whose header and footer are localized texts.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == Text {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } header: {
            Text(headerKey)
                .fontWeight(.medium)
        } footer: {
            Text(footerKey)
                .font(.caption)
        }
    }

    /// Initializes a ``LuminareSection`` without a footer.
    ///
    /// - Parameters:
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    ///   - header: the header.
    init(
        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) where Footer == EmptyView {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } header: {
            header()
        } footer: {
            EmptyView()
        }
    }

    /// Initializes a ``LuminareSection`` without a footer, whose header is a text.
    ///
    /// - Parameters:
    ///   - header: the header text.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    @_disfavoredOverload
    init(
        _ header: some StringProtocol,

        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == EmptyView {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } header: {
            Text(header)
                .fontWeight(.medium)
        }
    }

    /// Initializes a ``LuminareSection`` without a footer, whose header is a localized text.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        _ headerKey: LocalizedStringKey,

        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == EmptyView {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } header: {
            Text(headerKey)
                .fontWeight(.medium)
        }
    }

    /// Initializes a ``LuminareSection`` without a header.
    ///
    /// - Parameters:
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    ///   - footer: the footer.
    init(
        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } header: {
            EmptyView()
        } footer: {
            footer()
        }
    }

    /// Initializes a ``LuminareSection`` without a header, whose footer is a text.
    ///
    /// - Parameters:
    ///   - footer: the footer text.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    @_disfavoredOverload
    init(
        footer: some StringProtocol,

        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == Text {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } footer: {
            Text(footer)
                .font(.caption)
        }
    }

    /// Initializes a ``LuminareSection`` without a header, whose footer is a localized text.
    ///
    /// - Parameters:
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        footerKey: LocalizedStringKey,

        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == Text {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } footer: {
            Text(footerKey)
                .font(.caption)
        }
    }

    /// Initializes a ``LuminareSection`` without a header and a footer.
    ///
    /// - Parameters:
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            headerSpacing: headerSpacing,
            footerSpacing: footerSpacing,
            outerPadding: outerPadding
        ) {
            content()
        } header: {
            EmptyView()
        } footer: {
            EmptyView()
        }
    }
}
