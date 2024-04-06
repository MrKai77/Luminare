//
//  DividedVStack.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

// Thank you https://movingparts.io/variadic-views-in-swiftui
public struct DividedVStack<Content: View>: View {
    let spacing: CGFloat?
    let applyMaskToItems: Bool
    var content: Content

    public init(spacing: CGFloat? = nil, applyMaskToItems: Bool = true, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.applyMaskToItems = applyMaskToItems
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(
            DividedVStackLayout(
                spacing: self.spacing,
                applyMaskToItems: applyMaskToItems
            )
        ) {
            content
        }
    }
}

struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
    let spacing: CGFloat
    let applyMaskToItems: Bool

    init(spacing: CGFloat?, applyMaskToItems: Bool) {
        self.spacing = spacing ?? self.innerPadding
        self.applyMaskToItems = applyMaskToItems
    }

    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: self.spacing) {
            ForEach(children) { child in
                if applyMaskToItems {
                    child
                        .mask {
                            getMask(first, last, child.id)
                        }
                        .padding(.horizontal, innerPadding) // already applied vertically with spacing
                } else {
                    child
                }

                if child.id != last {
                    if applyMaskToItems {
                        Divider()
                            .padding(.horizontal, 1)
                    } else {
                        Divider()
                    }
                }
            }
        }
        .padding(.vertical, innerPadding)
    }

    func getMask(_ first: AnyHashable?, _ last: AnyHashable?, _ current: AnyHashable) -> some View {
        if first == last {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: cornerRadius - innerPadding,
                style: .continuous
            )
        } else if current == first {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding,
                style: .continuous
            )
        } else if current == last {
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
}
