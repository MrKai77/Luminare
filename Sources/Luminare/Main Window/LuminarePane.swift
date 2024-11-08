//
//  LuminarePane.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

// MARK: - Pane

/// A stylized pane that well distributes its content to cooperate with the ``LuminareWindow``.
public struct LuminarePane<Header, Content>: View where Header: View, Content: View {
    // MARK: Fields

    private let titlebarHeight: CGFloat = 50

    @ViewBuilder private let content: () -> Content, header: () -> Header

    @State private var clickedOutsideFlag = false

    // MARK: Initializers

    /// Initializes a ``LuminarePane``.
    ///
    /// - Parameters:
    ///   - content: the content view.
    ///   - header: the header that is located at the titlebar's position.
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.content = content
        self.header = header
    }

    /// Initializes a ``LuminarePane`` where the header is a localized text.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the header text.
    ///   - content: the content view.
    public init(
        _ key: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) where Header == Text {
        self.init(content: content) {
            Text(key)
        }
    }

    // MARK: Body

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

// MARK: - Button Style (Tab Header)

struct TabHeaderButtonStyle: ButtonStyle {
    @Environment(\.luminareAnimationFast) private var animationFast

    @State var isHovering: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isHovering ? .primary : .secondary)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
    }
}
