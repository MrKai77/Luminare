//
//  LuminarePane.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminarePane<Header, Content>: View where Header: View, Content: View {
    let titlebarHeight: CGFloat = 50

    @ViewBuilder let content: () -> Content
    @ViewBuilder let header: () -> Header

    @State private var clickedOutsideFlag = false

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.content = content
        self.header = header
    }
    
    public init(
        _ key: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text {
        self.init(content: content) {
            Text(key)
        }
    }

    public var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    content()
                }
                .padding(12)
                .environment(\.clickedOutsideFlag, clickedOutsideFlag)
                .background {
                    Color.white.opacity(0.0001)
                        .onTapGesture {
                            clickedOutsideFlag.toggle()
                        }
                        .ignoresSafeArea()
                }
            }
            .clipped()

            VStack(spacing: 0) {
                header()
                    .buttonStyle(TabHeaderButtonStyle())
                    .padding(.horizontal, 10)
                    .padding(.trailing, 5)
                    .frame(height: titlebarHeight, alignment: .leading)

                Divider()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .edgesIgnoringSafeArea(.top)
        }
        .luminareBackground()
    }
}

struct TabHeaderButtonStyle: ButtonStyle {
    @State var isHovering: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isHovering ? .primary : .secondary)
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
                    isHovering = hover
                }
            }
    }
}
