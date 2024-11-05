//
//  LuminareDividedStack.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// The orientation of a ``LuminareDividedStack``.
public enum LuminareDividedStackOrientation {
    /// Stacks elements vertically.
    case vertical
    /// Stacks elements horizontally.
    case horizontal
}

// MARK: - Divided Stack

/// A stylized stack that divides its content into groups, separated by division lines.
///
/// This is the root view of a ``LuminareWindow`` in common practice.
/// Typically, you are likely to wrap a ``LuminareSidebar`` inside along with a ``LuminarePane`` to create a tabbed content.
public struct LuminareDividedStack<Content>: View where Content: View {
    /// A local typealias identical to ``LuminareDividedStackOrientation``.
    public typealias Orientation = LuminareDividedStackOrientation

    // MARK: Fields

    private let orientation: Orientation
    
    @ViewBuilder private let content: () -> Content
    
    // MARK: Initializers
    
    /// Initializes a ``LuminareDividedStack``.
    ///
    /// - Parameter orientation: the ``Orientation`` that configures the direction to stack elements.
    /// - Parameter content: the content view of the stack.
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
        _VariadicView.Tree(LuminareDividedHStackLayout()) {
            content()
        }
    }

    @ViewBuilder
    private func makeVerticalStack() -> some View {
        _VariadicView.Tree(LuminareDividedVStackLayout()) {
            content()
        }
    }
}

// MARK: - Layouts

// MARK: Horizontal

struct LuminareDividedHStackLayout: _VariadicView_UnaryViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
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

struct LuminareDividedVStackLayout: _VariadicView_UnaryViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
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
