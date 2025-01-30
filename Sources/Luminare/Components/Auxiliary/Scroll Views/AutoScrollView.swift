//
//  AutoScrollView.swift
//  Luminare
//
//  Created by KrLite on 2024/11/5.
//

import SwiftUI

/// A simple scroll view that enables scrolling only if the content is large enough to scroll.
public struct AutoScrollView<Content>: View where Content: View {
    @Environment(\.luminareContentMarginsTop) private var contentMarginsTop
    @Environment(\.luminareContentMarginsLeading) private var contentMarginsLeading
    @Environment(\.luminareContentMarginsBottom) private var contentMarginsBottom
    @Environment(\.luminareContentMarginsTrailing) private var contentMarginsTrailing

    private let axes: Axis.Set
    private let showsIndicators: Bool
    @ViewBuilder private var content: () -> Content

    @State private var contentSize: CGSize = .zero
    @State private var containerSize: CGSize = .zero

    /// Initializes a ``AutoScrollView``.
    ///
    /// - Parameters:
    ///   - axes: the axes of the scroll view.
    ///   - showsIndicators: whether to show the scroll indicators.
    ///   - content: the content to scroll.
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }

    public var body: some View {
        ScrollView(allowedAxes, showsIndicators: showsIndicators) {
            VStack(spacing: 0) {
                if contentMarginsTop > 0 {
                    Spacer()
                        .frame(height: contentMarginsTop)
                }

                content()
                    .padding(.leading, contentMarginsLeading)
                    .padding(.trailing, contentMarginsTrailing)

                if contentMarginsBottom > 0 {
                    Spacer()
                        .frame(height: contentMarginsBottom)
                }
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                contentSize = size
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            containerSize = size
        }
        .scrollDisabled(isHorizontalScrollingDisabled && isVerticalScrollingDisabled)
    }

    private var allowedAxes: Axis.Set {
        if isHorizontalScrollingDisabled, isVerticalScrollingDisabled {
            axes
        } else if isHorizontalScrollingDisabled {
            axes.intersection(.vertical)
        } else if isVerticalScrollingDisabled {
            axes.intersection(.horizontal)
        } else {
            axes
        }
    }

    private var isHorizontalScrollingDisabled: Bool {
        guard axes.contains(.horizontal) else { return true }
        return contentSize.width <= containerSize.width
    }

    private var isVerticalScrollingDisabled: Bool {
        guard axes.contains(.vertical) else { return true }
        return contentSize.height <= containerSize.height
    }
}

@available(macOS 15.0, *)
#Preview(
    "AutoScrollView",
    traits: .sizeThatFitsLayout
) {
    AutoScrollView {
        Color.red
            .frame(height: 300)
    }
    .luminareContentMargins(.vertical, 50)
    .frame(width: 100, height: 300)
}
