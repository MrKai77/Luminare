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

    let innerPadding: CGFloat = 4

    init(spacing: CGFloat?, applyMaskToItems: Bool) {
        self.spacing = spacing ?? self.innerPadding
        self.applyMaskToItems = applyMaskToItems
    }

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: self.spacing) {
            ForEach(children) { child in
                if applyMaskToItems {
                    child
                        .modifier(
                            LuminareCroppedSectionItem(
                                isFirstChild: child.id == first,
                                isLastChild: child.id == last
                            )
                        )
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
}

public struct LuminareCroppedSectionItem: ViewModifier {
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    let isFirstChild: Bool
    let isLastChild: Bool

    public init(isFirstChild: Bool, isLastChild: Bool) {
        self.isFirstChild = isFirstChild
        self.isLastChild = isLastChild
    }

    public func body(content: Content) -> some View {
        content
            .mask(self.getMask())
            .padding(.horizontal, innerPadding)
    }

    func getMask() -> some View {
        if isFirstChild && isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: cornerRadius - innerPadding,
                style: .continuous
            )
        } else if isFirstChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding,
                style: .continuous
            )
        } else if isLastChild {
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
