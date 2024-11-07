//
//  LuminareSidebar.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

/// A stylized sidebar for ``LuminareWindow``.
public struct LuminareSidebar<Content>: View where Content: View {
    @ViewBuilder private let content: () -> Content

    /// Initializes a ``LuminareSidebar``.
    ///
    /// - Parameter content: the sidebar content. Typically multiple ``LuminareSidebarTab`` organized by
    /// ``LuminareSidebarSection``.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        AutoScrollView(.vertical) {
            VStack(spacing: 24) {
                content()
            }
        }
        .scrollIndicators(.never)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 12)
        .frame(maxHeight: .infinity, alignment: .top)
        .luminareBackground()
    }
}

// MARK: - Previews

#Preview("LuminareSidebar") {
    HStack {
        VStack {
            Text("Scrollable")

            LuminareSidebar {
                ForEach(0..<100) { num in
                    Text("\(num)")
                        .frame(width: 150, height: 35)
                        .modifier(LuminareBordered())
                }
            }
        }

        VStack {
            Text("Static")

            LuminareSidebar {
                ForEach(0..<5) { num in
                    Text("\(num)")
                        .frame(width: 150, height: 35)
                        .modifier(LuminareBordered())
                }
            }
        }
    }
    .frame(height: 450)
    .padding()
}
