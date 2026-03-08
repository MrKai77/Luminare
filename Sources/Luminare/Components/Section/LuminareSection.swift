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
    @Environment(\.luminareBorderedStates) private var borderedStates
    @Environment(\.luminareHasDividers) private var hasDividers
    @Environment(\.luminareSectionLayout) private var layout
    @Environment(\.luminareSectionMaxWidth) private var maxWidth

    // MARK: Fields

    private let headerSpacing: CGFloat
    private let footerSpacing: CGFloat
    private let outerPadding: CGFloat
    private let clipped: Bool

    @ViewBuilder private var content: () -> Content, header: () -> Header, footer: () -> Footer

    private var showHeader: Bool {
        Header.self != EmptyView.self
    }

    private var showFooter: Bool {
        Footer.self != EmptyView.self
    }

    // MARK: Initializers

    /// Initializes a ``LuminareSection``.
    ///
    /// - Parameters:
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - outerPadding: the padding around the contents.
    ///   - content: the content.
    ///   - header: the header.
    ///   - footer: the footer.
    public init(
        headerSpacing: CGFloat = 2,
        footerSpacing: CGFloat = 2,
        outerPadding: CGFloat = 4,
        clipped: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.headerSpacing = headerSpacing
        self.footerSpacing = footerSpacing
        self.outerPadding = outerPadding
        self.clipped = clipped
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

    @ViewBuilder
    private func wrappedContent() -> some View {
        if clipped {
            styledContent()
                .clipped()
        } else {
            styledContent()
        }
    }

    private func styledContent() -> some View {
        Group {
            if borderedStates.contains(.normal) {
                LuminareSectionStack(hasDividers: hasDividers, content: content)
                    .compositingGroup()
                    .frame(maxWidth: maxWidth == 0 ? nil : maxWidth)
                    .fixedSize(horizontal: maxWidth == 0, vertical: false)
                    .environment(\.luminareIsInsideSection, true)
                    .luminareRoundingBehavior(top: false, bottom: false)
                    .luminarePlateau()
            } else {
                content()
            }
        }
        .padding(.top, showHeader ? outerPadding : 0)
        .padding(.bottom, showFooter ? outerPadding : 0)
    }

    @ViewBuilder private func wrappedHeader() -> some View {
        if showHeader {
            header()
                .foregroundStyle(.secondary)
                .padding(.bottom, headerSpacing)
                .padding(.horizontal, outerPadding)
                .padding(.leading, cornerRadii.topLeading / 2)
                .padding(.trailing, cornerRadii.topTrailing / 2)
        }
    }

    @ViewBuilder private func wrappedFooter() -> some View {
        if showFooter {
            footer()
                .foregroundStyle(.secondary)
                .padding(.top, footerSpacing)
                .padding(.horizontal, outerPadding)
                .padding(.leading, cornerRadii.bottomLeading / 2)
                .padding(.trailing, cornerRadii.bottomTrailing / 2)
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

        LuminareButton(
            "Button",
            "Click Me!"
        ) {}

        Text("""
        Lorem eu cupidatat consectetur cupidatat est labore irure dolore dolore deserunt consequat. \
        Proident non est aliquip consectetur quis dolor. Incididunt aute do ea fugiat dolor. \
        Cillum cillum enim exercitation dolor do. \
        Deserunt ipsum aute non occaecat commodo adipisicing non. In est incididunt esse et.
        """)
        .padding(8)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
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
}
