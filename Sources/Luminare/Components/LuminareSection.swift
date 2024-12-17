//
//  LuminareSection.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public enum LuminareSectionLayout: Hashable, Equatable, Codable, Sendable {
    case section
    case stacked(spacing: CGFloat = 0)

    public static var stacked: Self {
        .stacked()
    }
}

// MARK: - Section

/// A stylized content wrapper with a header and a footer.
public struct LuminareSection<Header, Content, Footer>: View where Header: View, Content: View, Footer: View {
    // MARK: Environments

    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareIsBordered) private var isBordered
    @Environment(\.luminareHasDividers) private var hasDividers
    @Environment(\.luminareSectionLayout) private var layout
    @Environment(\.luminareSectionMaterial) private var material
    @Environment(\.luminareSectionMaxWidth) private var maxWidth
    @Environment(\.luminareSectionIsMasked) private var isMasked

    // MARK: Fields

    private let hasPadding: Bool

    private let headerSpacing: CGFloat, footerSpacing: CGFloat
    private let innerPadding: CGFloat

    @ViewBuilder private var content: () -> Content, header: () -> Header, footer: () -> Footer

    // MARK: Initializers

    /// Initializes a ``LuminareSection``.
    ///
    /// - Parameters:
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    ///   - header: the header.
    ///   - footer: the footer.
    public init(
        hasPadding: Bool = true,
        headerSpacing: CGFloat = 2, footerSpacing: CGFloat = 2,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.hasPadding = hasPadding
        self.headerSpacing = headerSpacing
        self.footerSpacing = footerSpacing
        self.innerPadding = innerPadding
        self.content = content
        self.header = header
        self.footer = footer
    }

    // MARK: Body

    public var body: some View {
        switch layout {
        case .section:
            Section {
                wrappedContent()
            } header: {
                wrappedHeader()
            } footer: {
                wrappedFooter()
            }
        case let .stacked(spacing):
            VStack(alignment: .leading, spacing: spacing) {
                wrappedHeader()

                wrappedContent()

                wrappedFooter()
            }
        }
    }

    @ViewBuilder private func wrappedContent() -> some View {
        Group {
            if isBordered {
                DividedVStack(isMasked: hasPadding, hasDividers: hasDividers) {
                    content()
                }
                .frame(maxWidth: maxWidth)
                .background(.quinary, with: material)
                .clipShape(.rect(cornerRadii: cornerRadii))
                .overlay {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii)
                        .strokeBorder(.quaternary)
                }
            } else {
                content()
                    .clipShape(.rect(cornerRadii: isMasked ? cornerRadii : .zero))
            }
        }
        .padding(hasPadding ? innerPadding : 0)
    }

    @ViewBuilder private func wrappedHeader() -> some View {
        if Header.self != EmptyView.self {
            header()
                .foregroundStyle(.secondary)
                .padding(.bottom, headerSpacing)
                .padding(.horizontal, hasPadding ? innerPadding : 0)
        }
    }

    @ViewBuilder private func wrappedFooter() -> some View {
        if Footer.self != EmptyView.self {
            footer()
                .foregroundStyle(.secondary)
                .padding(.top, footerSpacing)
                .padding(.horizontal, hasPadding ? innerPadding : 0)
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

        LuminareCompose("Button") {
            Button {} label: {
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
        .fixedSize(horizontal: false, vertical: true)
    } header: {
        HStack(alignment: .bottom) {
            Text("Section Header")

            Spacer()

            HStack(alignment: .bottom) {
                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.tint)
                }

                Button {} label: {
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
    .buttonStyle(.luminareCompact)
}
