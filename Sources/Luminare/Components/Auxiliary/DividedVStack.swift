//
//  DividedVStack.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//
//  Thanks to https://movingparts.io/variadic-views-in-swiftui

import SwiftUI

// MARK: - Divided Vertical Stack

public struct DividedVStack<Content>: View where Content: View {
    // MARK: Fields
    
    private let spacing: CGFloat?
    private let applyMaskToItems: Bool
    private let hasDividers: Bool
    
    @ViewBuilder private let content: () -> Content

    // MARK: Initializers

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
    
    // MARK: Body

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

// MARK: - Layouts

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

// MARK: - Cropped Section Item

public struct LuminareCroppedSectionItem: ViewModifier {
    // MARK: Fields
    
    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    private let isFirstChild: Bool
    private let isLastChild: Bool
    
    // MARK: Initializers

    public init(isFirstChild: Bool, isLastChild: Bool) {
        self.isFirstChild = isFirstChild
        self.isLastChild = isLastChild
    }
    
    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .mask(mask())
            .padding(.horizontal, innerPadding)
    }

    @ViewBuilder private func mask() -> some View {
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

// MARK: - Preview

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
