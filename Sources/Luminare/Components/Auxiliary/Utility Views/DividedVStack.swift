//
//  DividedVStack.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-02.
//
//  Thanks to https://movingparts.io/variadic-views-in-swiftui and https://github.com/lorenzofiamingo/swiftui-variadic-views

import SwiftUI
import VariadicViews

// MARK: - Divided Vertical Stack

/// A vertical stack with optional dividers between elements.
public struct DividedVStack<Content>: View where Content: View {
    // MARK: Fields

    private let spacing: CGFloat?
    private let isMasked: Bool
    private let hasDividers: Bool

    @ViewBuilder private var content: () -> Content

    // MARK: Initializers

    /// Initializes a ``DividedVStack``.
    ///
    /// - Parameters:
    ///   - spacing: the spacing between elements.
    ///   - isMasked: whether the elements are masked to match their borders.
    ///   - hasDividers: whether to show the dividers between elements.
    ///   - content: the content.
    public init(
        spacing: CGFloat? = nil,
        isMasked: Bool = true,
        hasDividers: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.isMasked = isMasked
        self.hasDividers = hasDividers
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        UnaryVariadicView(content()) { children in
            DividedVStackVariadic(
                children: children,
                spacing: isMasked ? spacing : 0,
                isMasked: isMasked,
                hasDividers: hasDividers
            )
        }
    }
}

// MARK: - Layouts

struct DividedVStackVariadic: View {
    let children: VariadicViewChildren
    let spacing: CGFloat
    let innerPadding: CGFloat
    let isMasked: Bool
    let hasDividers: Bool

    init(
        children: VariadicViewChildren,
        spacing: CGFloat?,
        innerPadding: CGFloat = 4,
        isMasked: Bool,
        hasDividers: Bool
    ) {
        self.children = children
        self.spacing = spacing ?? innerPadding
        self.innerPadding = innerPadding
        self.isMasked = isMasked
        self.hasDividers = hasDividers
    }

    var body: some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: hasDividers ? spacing : spacing / 2) {
            ForEach(children) { child in
                Group {
                    if isMasked {
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

// MARK: - Preview

#Preview {
    LuminareSection {
        DividedVStack {
            ForEach(37 ..< 43) { num in
                Text("\(num)")
            }
        }
    }
    .padding()
}
