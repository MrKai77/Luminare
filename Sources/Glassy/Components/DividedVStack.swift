//
//  DividedVStack.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

// Thank you https://movingparts.io/variadic-views-in-swiftui
public struct DividedVStack<Content: View>: View {
    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(DividedVStackLayout()) {
            content
        }
    }
}

struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: self.innerPadding) {
            ForEach(children) { child in
                child
                    .mask {
                        if first == last {
                            UnevenRoundedRectangle(
                                topLeadingRadius: cornerRadius - innerPadding,
                                bottomLeadingRadius: cornerRadius - innerPadding,
                                bottomTrailingRadius: cornerRadius - innerPadding,
                                topTrailingRadius: cornerRadius - innerPadding,
                                style: .continuous
                            )
                        } else if child.id == first {
                            UnevenRoundedRectangle(
                                topLeadingRadius: cornerRadius - innerPadding,
                                bottomLeadingRadius: innerCornerRadius,
                                bottomTrailingRadius: innerCornerRadius,
                                topTrailingRadius: cornerRadius - innerPadding,
                                style: .continuous
                            )
                        } else if child.id == last {
                            UnevenRoundedRectangle(
                                topLeadingRadius: innerCornerRadius,
                                bottomLeadingRadius: cornerRadius - innerPadding,
                                bottomTrailingRadius: cornerRadius - innerPadding,
                                topTrailingRadius: innerCornerRadius,
                                style: .continuous
                            )
                        } else {
                            UnevenRoundedRectangle(
                                topLeadingRadius: innerCornerRadius,
                                bottomLeadingRadius: innerCornerRadius,
                                bottomTrailingRadius: innerCornerRadius,
                                topTrailingRadius: innerCornerRadius,
                                style: .continuous
                            )
                        }
                    }
                    .padding(.horizontal, innerPadding) // already applied vertically with spacing

                if child.id != last {
                    Divider()
                }
            }
        }
        .padding(.vertical, innerPadding)
    }
}
