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

    private let isMasked: Bool
    private let hasDividers: Bool

    @ViewBuilder private var content: () -> Content

    // MARK: Initializers

    /// Initializes a ``DividedVStack``.
    ///
    /// - Parameters:
    ///   - isMasked: whether the elements are masked to match their borders.
    ///   - hasDividers: whether to show the dividers between elements.
    ///   - content: the content.
    public init(
        isMasked: Bool = true,
        hasDividers: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isMasked = isMasked
        self.hasDividers = hasDividers
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        UnaryVariadicView(content()) { children in
            DividedVStackVariadic(
                children: children,
                isMasked: isMasked,
                hasDividers: hasDividers
            )
        }
    }
}

// MARK: - Layouts

struct DividedVStackVariadic: View {
    let children: VariadicViewChildren
    let innerPadding: CGFloat
    let isMasked: Bool
    let hasDividers: Bool

    init(
        children: VariadicViewChildren,
        innerPadding: CGFloat = 4,
        isMasked: Bool,
        hasDividers: Bool
    ) {
        self.children = children
        self.innerPadding = innerPadding
        self.isMasked = isMasked
        self.hasDividers = hasDividers
    }

    var body: some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: 0) {
            ForEach(children) { child in
                DividedVStackChildView(
                    child: child,
                    innerPadding: innerPadding,
                    isFirstChild: child.id == first,
                    isLastChild: child.id == last,
                    isMasked: isMasked
                )

                if hasDividers, child.id != last {
                    Divider()
                        .padding(.horizontal, 1)
                }
            }
        }
    }
}

struct DividedVStackChildView: View {
    let child: VariadicViewChildren.Element
    let innerPadding: CGFloat
    let isFirstChild: Bool
    let isLastChild: Bool
    let isMasked: Bool

    @State private var overrideDisableInnerPadding: Bool? = nil

    var body: some View {
        Group {
            if isMasked {
                child
                    .modifier(
                        LuminareCroppedSectionItem(
                            innerPadding: overrideDisableInnerPadding == true ? 0 : innerPadding,
                            isFirstChild: isFirstChild,
                            isLastChild: isLastChild
                        )
                    )
                    .padding(.top, isFirstChild ? 1 : 0)
                    .padding(.bottom, isLastChild ? 1 : 0)
                    .padding(.horizontal, 1)
                    .padding(.top, overrideDisableInnerPadding != true ? innerPadding : 0)
                    .padding(.bottom, overrideDisableInnerPadding != true ? innerPadding : 0)
            } else {
                child
                    .mask(Rectangle()) // fixes hover areas for some reason
            }
        }
        .readPreference(
            DisableDividedStackInnerPaddingKey.self,
            to: $overrideDisableInnerPadding
        )
    }
}

// MARK: - Preference Key

struct DisableDividedStackInnerPaddingKey: PreferenceKey {
    typealias Value = Bool?
    static var defaultValue: Value = nil

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
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
