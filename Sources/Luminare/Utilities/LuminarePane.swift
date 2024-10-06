//
//  LuminarePane.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminarePane<V, C>: View where V: View, C: View {
    @Environment(\.luminareWindow) var window
    let titlebarHeight: CGFloat = 50

    let header: () -> C
    let content: () -> V

    @State private var clickedOutsideFlag: Bool = false

    public init(
        @ViewBuilder header: @escaping () -> C,
        @ViewBuilder content: @escaping () -> V
    ) {
        self.header = header
        self.content = content
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
                            print("Clicked")
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
