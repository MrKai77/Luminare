//
//  LuminareSection.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

public struct LuminareSection<Header, Content, Footer>: View where Header: View, Content: View, Footer: View {
    let disablePadding: Bool
    let showDividers: Bool
    let noBorder: Bool
    
    let headerSpacing: CGFloat
    let footerSpacing: CGFloat
    let cornerRadius: CGFloat
    let innerPadding: CGFloat
    
    @ViewBuilder let content: () -> Content
    @ViewBuilder let header: () -> Header
    @ViewBuilder let footer: () -> Footer

    public init(
        disablePadding: Bool = false,
        showDividers: Bool = true,
        noBorder: Bool = false,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.disablePadding = disablePadding
        self.showDividers = showDividers
        self.noBorder = noBorder
        self.headerSpacing = headerSpacing
        self.footerSpacing = footerSpacing
        self.cornerRadius = cornerRadius
        self.innerPadding = innerPadding
        self.content = content
        self.header = header
        self.footer = footer
    }
    
    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        disablePadding: Bool = false,
        showDividers: Bool = true,
        noBorder: Bool = false,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == Text {
        self.init(
            disablePadding: disablePadding,
            showDividers: showDividers,
            noBorder: noBorder,
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
    
    public init(
        disablePadding: Bool = false,
        showDividers: Bool = true,
        noBorder: Bool = false,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) where Footer == EmptyView {
        self.init(
            disablePadding: disablePadding,
            showDividers: showDividers,
            noBorder: noBorder,
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
    
    public init(
        headerKey: LocalizedStringKey,
        disablePadding: Bool = false,
        showDividers: Bool = true,
        noBorder: Bool = false,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text, Footer == EmptyView {
        self.init(
            disablePadding: disablePadding,
            showDividers: showDividers,
            noBorder: noBorder,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
        ) {
            content()
        } header: {
            Text(headerKey)
        }
    }
    
    public init(
        disablePadding: Bool = false,
        showDividers: Bool = true,
        noBorder: Bool = false,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView {
        self.init(
            disablePadding: disablePadding,
            showDividers: showDividers,
            noBorder: noBorder,
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
    
    public init(
        footerKey: LocalizedStringKey,
        disablePadding: Bool = false,
        showDividers: Bool = true,
        noBorder: Bool = false,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == Text {
        self.init(
            disablePadding: disablePadding,
            showDividers: showDividers,
            noBorder: noBorder,
            headerSpacing: headerSpacing, footerSpacing: footerSpacing,
            cornerRadius: cornerRadius, innerPadding: innerPadding
        ) {
            content()
        } footer: {
            Text(footerKey)
        }
    }
    
    public init(
        disablePadding: Bool = false,
        showDividers: Bool = true,
        noBorder: Bool = false,
        headerSpacing: CGFloat = 8, footerSpacing: CGFloat = 8,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            disablePadding: disablePadding,
            showDividers: showDividers,
            noBorder: noBorder,
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

    public var body: some View {
        VStack(spacing: 0) {
            if Header.self != EmptyView.self {
                HStack {
                    header()
                    
                    Spacer()
                }
                .foregroundStyle(.secondary)
                
                Spacer()
                    .frame(height: headerSpacing)
            }
            
            if noBorder {
                content()
            } else {
                DividedVStack(applyMaskToItems: !disablePadding, showDividers: showDividers) {
                    content()
                }
                .frame(maxWidth: .infinity)
                .background(.quinary)
                .clipShape(.rect(cornerRadius: cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
            }
            
            if Footer.self != EmptyView.self {
                Spacer()
                    .frame(height: footerSpacing)
                
                HStack {
                    footer()
                    
                    Spacer()
                }
                .foregroundStyle(.secondary)
            }

        }
    }
}

#Preview {
    LuminareSection {
        Text("Content")
    } header: {
        Text("Header")
    } footer: {
        Text("Footer")
    }
    .padding()
}
