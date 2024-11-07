//
//  AutoScrollView.swift
//  
//
//  Created by KrLite on 2024/11/5.
//

import SwiftUI

public struct AutoScrollView<Content>: View where Content: View {
    private let axes: Axis.Set
    private let showsIndicators: Bool
    @ViewBuilder private let content: () -> Content

    @State private var contentSize: CGSize = .zero
    @State private var containerSize: CGSize = .zero

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
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
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
        .scrollDisabled(isHorizontalScrollDisabled && isVerticalScrollDisabled)
    }

    private var isHorizontalScrollDisabled: Bool {
        guard axes.contains(.horizontal) else { return true }
        return contentSize.width <= containerSize.width
    }

    private var isVerticalScrollDisabled: Bool {
        guard axes.contains(.vertical) else { return true }
        return contentSize.height <= containerSize.height
    }
}
