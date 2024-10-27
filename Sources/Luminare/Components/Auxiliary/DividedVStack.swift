//
//  DividedVStack.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//
//  Thanks to https://movingparts.io/variadic-views-in-swiftui

import SwiftUI

public struct DividedVStack<Content>: View where Content: View {
    let spacing: CGFloat?
    let applyMaskToItems: Bool
    let hasDividers: Bool
    
    @ViewBuilder let content: () -> Content

    public init(
        spacing: CGFloat? = nil,
        applyMaskToItems: Bool = true,
        hasDividers: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.applyMaskToItems = applyMaskToItems
        self.hasDividers = hasDividers
        self.content = content
    }

    public var body: some View {
        _VariadicView.Tree(
            DividedVStackLayout(
                spacing: applyMaskToItems ? spacing : 0,
                applyMaskToItems: applyMaskToItems,
                hasDividers: hasDividers
            )
        ) {
            content()
        }
    }
}

struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
    let spacing: CGFloat
    let applyMaskToItems: Bool
    let hasDividers: Bool
    let innerPadding: CGFloat = 4

    init(spacing: CGFloat?, applyMaskToItems: Bool, hasDividers: Bool) {
        self.spacing = spacing ?? innerPadding
        self.applyMaskToItems = applyMaskToItems
        self.hasDividers = hasDividers
    }

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: hasDividers ? spacing : spacing / 2) {
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
                            .mask(Rectangle()) // fixes hover areas for some reason
                            .padding(.vertical, -4)
                    }
                }

                if hasDividers, child.id != last {
                    Divider()
                        .padding(.horizontal, 1)
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

    private let isFirstChild: Bool
    private let isLastChild: Bool

    public init(isFirstChild: Bool, isLastChild: Bool) {
        self.isFirstChild = isFirstChild
        self.isLastChild = isLastChild
    }

    public func body(content: Content) -> some View {
        content
            .mask(getMask())
            .padding(.horizontal, innerPadding)
    }

    func getMask() -> some View {
        if isFirstChild, isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if isFirstChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: innerCornerRadius
            )
        } else {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }
    }
}

#Preview {
    LuminareSection {
        DividedVStack {
            ForEach(37..<43) { num in
                Text("\(num)")
            }
        }
    }
    .padding()
}
