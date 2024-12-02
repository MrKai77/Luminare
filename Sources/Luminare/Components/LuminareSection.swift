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
    // MARK: Environments

    @Environment(\.luminareCornerRadius) private var cornerRadius
    @Environment(\.luminareSectionMaxWidth) private var maxWidth
    @Environment(\.luminareIsBordered) private var isBordered
    @Environment(\.luminareSectionIsMasked) private var isMasked

    // MARK: Fields

    private let hasPadding: Bool, hasDividers: Bool

    private let headerSpacing: CGFloat, footerSpacing: CGFloat
    private let innerPadding: CGFloat

    @ViewBuilder private let content: () -> Content, header: () -> Header, footer: () -> Footer

    // MARK: Initializers

    /// Initializes a ``LuminareSection``.
    ///
    /// - Parameters:
    ///   - hasPadding: whether to have paddings between divided contents.
    ///   - hasDividers: whether to display dividers between contents.
    ///   - headerSpacing: the spacing between header and content.
    ///   - footerSpacing: the spacing between footer and content.
    ///   - innerPadding: the padding around the contents.
    ///   - content: the content.
    ///   - header: the header.
    ///   - footer: the footer.
    public init(
        hasPadding: Bool = true,
        hasDividers: Bool = true,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.hasPadding = hasPadding
        self.hasDividers = hasDividers
        self.headerSpacing = headerSpacing
        self.footerSpacing = footerSpacing
        self.innerPadding = innerPadding
        self.content = content
        self.header = header
        self.footer = footer
    }

    // MARK: Body

    public var body: some View {
        Section {
            Group {
                if isBordered {
                    DividedVStack(isMasked: hasPadding, hasDividers: hasDividers) {
                        content()
                    }
                    .frame(maxWidth: maxWidth)
                    .background(.ultraThickMaterial)
                    .background(.quinary.opacity(0.5))
                    .clipShape(.rect(cornerRadius: cornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(.quaternary)
                    }
                } else {
                    content()
                        .clipShape(.rect(cornerRadius: isMasked ? cornerRadius : 0))
                }
            }
            .padding(innerPadding)
        } header: {
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
        } footer: {
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
    .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
}
