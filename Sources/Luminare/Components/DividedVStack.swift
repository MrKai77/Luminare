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
    let showDividers: Bool
    var content: Content

    public init(spacing: CGFloat? = nil, applyMaskToItems: Bool = true, showDividers: Bool = true, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.applyMaskToItems = applyMaskToItems
        self.showDividers = showDividers
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(
            DividedVStackLayout(
                spacing: self.applyMaskToItems ? self.spacing : 0,
                applyMaskToItems: applyMaskToItems,
                showDividers: showDividers
            )
        ) {
            content
        }
    }
}

struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
    let spacing: CGFloat
    let applyMaskToItems: Bool
    let showDividers: Bool

    let innerPadding: CGFloat = 4

    init(spacing: CGFloat?, applyMaskToItems: Bool, showDividers: Bool) {
        self.spacing = spacing ?? self.innerPadding
        self.applyMaskToItems = applyMaskToItems
        self.showDividers = showDividers
    }

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: self.showDividers ? self.spacing : self.spacing / 2) {
            ForEach(children) { child in
                Group {
                    if applyMaskToItems {
                        child
                            .modifier(
                                LuminareCroppedSectionItem(
                                    isFirstChild: child.id == first,
                                    isLastChild: child.id == last
                                )
                            )
                            .padding(.top, child.id == first ? 1 : 0)
                            .padding(.bottom, child.id == last ? 1 : 0)
                            .padding(.horizontal, 1)
                    } else {
                        child
                    }
                }

                if showDividers && child.id != last {
                    Divider()
                        .padding(.horizontal, 1)
                }
            }
        }
        .padding(.vertical, innerPadding)
    }
}

// TODO: FIX 3 vs 4 pt padding

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
