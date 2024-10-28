//
//  LuminareDividedStack.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminareDividedStack<Content: View>: View {
    public enum StackOrientation {
        case vertical
        case horizontal
    }

    private let orientation: StackOrientation
    
    @ViewBuilder private let content: () -> Content
    
    public init(orientation: StackOrientation = .horizontal, @ViewBuilder content: @escaping () -> Content) {
        self.orientation = orientation
        self.content = content
    }

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
