//
//  LuminareSection.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

// MARK: - Section

/// A stylized content wrapper with a header and a footer.
public struct LuminareSection<Header, Content, Footer>: View where Header: View, Content: View, Footer: View {
    // MARK: Fields

    private let hasPadding: Bool, hasDividers: Bool
    private let isBordered: Bool

    private let headerSpacing: CGFloat, footerSpacing: CGFloat
    private let cornerRadius: CGFloat, innerPadding: CGFloat

    @ViewBuilder private let content: () -> Content, header: () -> Header, footer: () -> Footer

    // MARK: Initializers

    /// Initializes a ``LuminareSection``.
    ///
    /// - Parameters:
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - hasDividers: whether to display dividers between contents.
    ///   - isBordered: whether to display a border.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - cornerRadius: the radius of the border.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the contents.
    ///   - header: the header.
    ///   - footer: the footer.
    public init(
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        isBordered: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.hasPadding = hasPadding
        self.hasDividers = hasDividers
        self.isBordered = isBordered
        self.headerSpacing = headerSpacing
        self.footerSpacing = footerSpacing
        self.cornerRadius = cornerRadius
        self.innerPadding = innerPadding
        self.content = content
        self.header = header
        self.footer = footer
    }
    
    /// Initializes a ``LuminareSection`` where the header and the footer are localized texts.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - hasDividers: whether to display dividers between contents.
    ///   - isBordered: whether to display a border.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - cornerRadius: the radius of the border.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the contents.
    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        isBordered: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == Text {
        self.init(
            hasPadding: hasPadding,
            hasDividers: hasDividers,
            isBordered: isBordered,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
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
    ///   - hasDividers: whether to display dividers between contents.
    ///   - isBordered: whether to display a border.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - cornerRadius: the radius of the border.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the contents.
    ///   - header: the header.
    public init(
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        isBordered: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) where Footer == EmptyView {
        self.init(
            hasPadding: hasPadding,
            hasDividers: hasDividers,
            isBordered: isBordered,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
        ) {
            content()
        } header: {
            header()
        } footer: {
            EmptyView()
        }
    }
    
    /// Initializes a ``LuminareSection`` without a footer, where the header is a localized text.
    ///
    /// - Parameters:
    ///   - headerKey: the `LocalizedStringKey` to look up the header text.
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - hasDividers: whether to display dividers between contents.
    ///   - isBordered: whether to display a border.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - cornerRadius: the radius of the border.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the contents.
    public init(
        _ headerKey: LocalizedStringKey,
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        isBordered: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == EmptyView {
        self.init(
            hasPadding: hasPadding,
            hasDividers: hasDividers,
            isBordered: isBordered,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
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
    ///   - hasDividers: whether to display dividers between contents.
    ///   - isBordered: whether to display a border.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - cornerRadius: the radius of the border.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the contents.
    ///   - footer: the footer.
    public init(
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        isBordered: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView {
        self.init(
            hasPadding: hasPadding,
            hasDividers: hasDividers,
            isBordered: isBordered,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
        ) {
            content()
        } header: {
            EmptyView()
        } footer: {
            footer()
        }
    }
    
    /// Initializes a ``LuminareSection`` without a header, where the footer is a localized text.
    ///
    /// - Parameters:
    ///   - footerKey: the `LocalizedStringKey` to look up the footer text.
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - hasDividers: whether to display dividers between contents.
    ///   - isBordered: whether to display a border.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - cornerRadius: the radius of the border.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the contents.
    public init(
        footerKey: LocalizedStringKey,
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        isBordered: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == Text {
        self.init(
            hasPadding: hasPadding,
            hasDividers: hasDividers,
            isBordered: isBordered,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
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
    ///   - hasDividers: whether to display dividers between contents.
    ///   - isBordered: whether to display a border.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - cornerRadius: the radius of the border.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the contents.
    public init(
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        isBordered: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            hasPadding: hasPadding,
            hasDividers: hasDividers,
            isBordered: isBordered,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
        ) {
            content()
        } header: {
            EmptyView()
        } footer: {
            EmptyView()
        }
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: 0) {
            if Header.self != EmptyView.self {
                Group {
                    if Header.self == Text.self {
                        HStack {
                            header()

                            Spacer()
                        }
                    } else {
                        header()
                    }
                }
                .foregroundStyle(.secondary)

                Spacer()
                    .frame(height: headerSpacing)
            }

            Group {
                if isBordered {
                    DividedVStack(applyMaskToItems: hasPadding, hasDividers: hasDividers) {
                        content()
                    }
                    .frame(maxWidth: .infinity)
                    .background(.quinary)
                    .clipShape(.rect(cornerRadius: cornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(.quaternary)
                    }
                } else {
                    content()
                }
            }
            .padding(innerPadding)

            if Footer.self != EmptyView.self {
                Spacer()
                    .frame(height: footerSpacing)

                Group {
                    if Footer.self == Text.self {
                        HStack {
                            footer()

                            Spacer()
                        }
                    } else {
                        footer()
                    }
                }
                .foregroundStyle(.secondary)
            }

        }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareSection",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        VStack {
            Image(systemName: "apple.logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 32)
                .foregroundStyle(.secondary)
        }
        .frame(height: 100)

        LuminareCompose("Button", reducesTrailingSpace: true) {
            Button {
            } label: {
                Text("Click Me!")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
        }

        Text("""
Lorem eu cupidatat consectetur cupidatat est labore irure dolore dolore deserunt consequat. \
Proident non est aliquip consectetur quis dolor. Incididunt aute do ea fugiat dolor. \
Cillum cillum enim exercitation dolor do. \
Deserunt ipsum aute non occaecat commodo adipisicing non. In est incididunt esse et.
""")
        .padding(8)
        .foregroundStyle(.secondary)
    } header: {
        HStack(alignment: .bottom) {
            Text("Section Header")

            Spacer()

            HStack(alignment: .bottom) {
                Button {
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.tint)
                }

                Button {
                } label: {
                    Image(systemName: "location")
                }
            }
            .buttonStyle(.borderless)
        }
    } footer: {
        HStack {
            Text("Section Footer")

            Spacer()
        }
    }
    .frame(width: 450)
    .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
}
