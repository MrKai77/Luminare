//
//  LuminarePane.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminarePane<V, C>: View where V: View, C: View {
    let header: () -> C
    let content: () -> V

    // Convenience init for a tab
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
                VStack(spacing: 16) {
                    content()
                }
                .padding(12)
            }
            .clipped()

            VStack(spacing: 0) {
                header()
                    .buttonStyle(TabHeaderButtonStyle())
                    .padding(.horizontal, 10)
                    .padding(.trailing, 5)
                    .frame(height: 51, alignment: .leading)

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
