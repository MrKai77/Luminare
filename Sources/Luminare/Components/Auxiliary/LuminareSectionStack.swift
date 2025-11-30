//
//  LuminareSectionStack.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-02.
//
//  Thanks to https://movingparts.io/variadic-views-in-swiftui and https://github.com/lorenzofiamingo/swiftui-variadic-views

import SwiftUI
import VariadicViews

// MARK: - Divided Vertical Stack

/// A vertical stack with optional dividers between elements.
public struct LuminareSectionStack<Content>: View where Content: View {
    // MARK: Fields

    private let hasDividers: Bool

    @ViewBuilder private var content: () -> Content

    // MARK: Initializers

    /// Initializes a ``LuminareSectionStack``.
    ///
    /// - Parameters:
    ///   - hasDividers: whether to show the dividers between elements.
    ///   - content: the content.
    public init(
        hasDividers: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hasDividers = hasDividers
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        UnaryVariadicView(content()) { children in
            DividedVStackVariadic(
                children: children,
                hasDividers: hasDividers
            )
        }
    }
}

// MARK: - Layouts

struct DividedVStackVariadic: View {
    let children: VariadicViewChildren
    let innerPadding: CGFloat
    let hasDividers: Bool

    init(
        children: VariadicViewChildren,
        innerPadding: CGFloat = 4,
        hasDividers: Bool
    ) {
        self.children = children
        self.innerPadding = innerPadding
        self.hasDividers = hasDividers
    }

    var body: some View {
        let first = children.first?.id
        let last = children.last?.id

        VStack(spacing: 0) {
            ForEach(children) { child in
                LuminareSectionStackChildView(
                    child: child,
                    innerPadding: innerPadding,
                    isFirstChild: child.id == first,
                    isLastChild: child.id == last
                )

                if hasDividers, child.id != last {
                    Divider()
                        .padding(.horizontal, 1)
                }
            }
        }
    }
}

struct LuminareSectionStackChildView: View {
    let child: VariadicViewChildren.Element
    let innerPadding: CGFloat
    let isFirstChild: Bool
    let isLastChild: Bool

    @State private var disableInnerPadding: Bool? = nil
    @State private var enableMask: Bool? = nil

    var body: some View {
        Group {
            child
                .compositingGroup()
                .modifier(
                    LuminareCroppedSectionItemModifier(
                        innerPadding: disableInnerPadding == true ? 0 : innerPadding,
                        isFirstChild: isFirstChild,
                        isLastChild: isLastChild,
                        isEnabled: enableMask == true
                    )
                )
                .padding(disableInnerPadding == true ? 0 : innerPadding)
                .padding(.top, isFirstChild ? 1 : 0)
                .padding(.bottom, isLastChild ? 1 : 0)
                .padding(.horizontal, 1)
        }
        .readPreference(
            LuminareSectionStackDisableInnerPaddingKey.self,
            to: $disableInnerPadding
        )
        .readPreference(
            LuminareSectionStackEnableMaskKey.self,
            to: $enableMask
        )
    }
}

// MARK: - Preference Key

struct LuminareSectionStackDisableInnerPaddingKey: PreferenceKey {
    typealias Value = Bool?
    static var defaultValue: Value { nil }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}

struct LuminareSectionStackEnableMaskKey: PreferenceKey {
    typealias Value = Bool?
    static var defaultValue: Value { nil }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}

// MARK: - Preview

#Preview {
    LuminareSection {
        LuminareSectionStack {
            ForEach(37 ..< 43) { num in
                Text("\(num)")
            }
        }
    }
    .padding()
}
