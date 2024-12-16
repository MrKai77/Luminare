//
//  LuminareSection+Initializers.swift
//  Luminare
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

public extension LuminareSection {
    /// Initializes a ``LuminareSection`` whose header and footer are localized texts.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        hasPadding: Bool = true,
        headerSpacing: CGFloat = 2, footerSpacing: CGFloat = 2,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == Text {
        self.init(
            hasPadding: hasPadding,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            innerPadding: innerPadding
        ) {
            content()
        } header: {
            Text(headerKey)
        } footer: {
            Text(footerKey)
        }
    }

    /// Initializes a ``LuminareSection`` without a footer.
    ///
    /// - Parameters:
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    ///   - header: the header.
    init(
        hasPadding: Bool = true,
        headerSpacing: CGFloat = 2, footerSpacing: CGFloat = 2,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) where Footer == EmptyView {
        self.init(
            hasPadding: hasPadding,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            innerPadding: innerPadding
        ) {
            content()
        } header: {
            header()
        } footer: {
            EmptyView()
        }
    }

    /// Initializes a ``LuminareSection`` without a footer, whose header is a localized text.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        _ headerKey: LocalizedStringKey,
        hasPadding: Bool = true,
        headerSpacing: CGFloat = 2, footerSpacing: CGFloat = 2,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == EmptyView {
        self.init(
            hasPadding: hasPadding,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            innerPadding: innerPadding
        ) {
            content()
        } header: {
            Text(headerKey)
        }
    }

    /// Initializes a ``LuminareSection`` without a header.
    ///
    /// - Parameters:
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    ///   - footer: the footer.
    init(
        hasPadding: Bool = true,
        headerSpacing: CGFloat = 2, footerSpacing: CGFloat = 2,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView {
        self.init(
            hasPadding: hasPadding,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            innerPadding: innerPadding
        ) {
            content()
        } header: {
            EmptyView()
        } footer: {
            footer()
        }
    }

    /// Initializes a ``LuminareSection`` without a header, whose footer is a localized text.
    ///
    /// - Parameters:
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        footerKey: LocalizedStringKey,
        hasPadding: Bool = true,
        headerSpacing: CGFloat = 2, footerSpacing: CGFloat = 2,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == Text {
        self.init(
            hasPadding: hasPadding,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            innerPadding: innerPadding
        ) {
            content()
        } footer: {
            Text(footerKey)
        }
    }

    /// Initializes a ``LuminareSection`` without a header and a footer.
    ///
    /// - Parameters:
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    init(
        hasPadding: Bool = true,
        headerSpacing: CGFloat = 2, footerSpacing: CGFloat = 2,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            hasPadding: hasPadding,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            innerPadding: innerPadding
        ) {
            content()
        } header: {
            EmptyView()
        } footer: {
            EmptyView()
        }
    }
}
