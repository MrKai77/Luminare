//
//  LuminareDividedStack.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI
import VariadicViews

/// The orientation of a ``LuminareDividedStack``.
public enum LuminareDividedStackOrientation: String, Equatable, Hashable, Identifiable, CaseIterable, Codable, Sendable {
    /// Stacks elements vertically.
    case vertical
    /// Stacks elements horizontally.
    case horizontal

    public var id: Self { self }
}

// MARK: - Divided Stack

/// A stylized stack that divides its content into groups, separated by division lines.
///
/// This is the root view of a ``LuminareWindow`` in common practice.
/// Typically, you are likely to wrap a ``LuminareSidebar`` inside along with a ``LuminarePane`` to create a tabbed
/// content.
public struct LuminareDividedStack<Content>: View where Content: View {
    /// A local typealias identical to ``LuminareDividedStackOrientation``.
    public typealias Orientation = LuminareDividedStackOrientation

    // MARK: Fields

    private let orientation: Orientation

    @ViewBuilder private var content: () -> Content

    // MARK: Initializers

    /// Initializes a ``LuminareDividedStack``.
    ///
    /// - Parameters:
    ///   - orientation: the ``Orientation`` that configures the direction to stack elements.
    ///   - content: the content view of the stack.
    public init(
        _ orientation: Orientation = .horizontal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.orientation = orientation
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        switch orientation {
        case .horizontal:
            makeHorizontalStack()
        case .vertical:
            makeVerticalStack()
        }
    }

    @ViewBuilder
    private func makeHorizontalStack() -> some View {
        UnaryVariadicView(content()) { children in
            LuminareDividedHStackVariadic(children: children)
        }
    }

    @ViewBuilder
    private func makeVerticalStack() -> some View {
        UnaryVariadicView(content()) { children in
            LuminareDividedVStackVariadic(children: children)
        }
    }
}

// MARK: - Layouts

// MARK: Horizontal

struct LuminareDividedHStackVariadic: View {
    var children: VariadicViewChildren

    var body: some View {
        HStack(spacing: 0) {
            ForEach(children) { child in
                child

                if child.id != children.last?.id {
                    Divider()
                        .edgesIgnoringSafeArea(.top)
                        .luminareBackground()
                }
            }
            .transition(.asymmetric(insertion: .identity, removal: .opacity.animation(.easeInOut(duration: 0.25))))
        }
    }
}

// MARK: Vertical

struct LuminareDividedVStackVariadic: View {
    var children: VariadicViewChildren

    var body: some View {
        VStack(spacing: 0) {
            ForEach(children) { child in
                child

                if child.id != children.last?.id {
                    Divider()
                        .luminareBackground()
                }
            }
            .transition(.asymmetric(insertion: .identity, removal: .opacity.animation(.easeInOut(duration: 0.25))))
        }
    }
}
