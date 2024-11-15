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
    /// - Parameters:
    ///   - content: the sidebar content.
    ///   Typically multiple ``LuminareSidebarTab`` organized by ``LuminareSidebarSection``.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        if #available(macOS 14.0, *) {
            let overflow: CGFloat = 50
            
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

            .padding(.top, -overflow)
            .contentMargins(.top, overflow)
            .mask {
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [.clear, .white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: overflow)
                    
                    Color.white
                }
                .padding(.top, -overflow)
            }
        } else {
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
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareSidebar",
    traits: .sizeThatFitsLayout
) {
    HStack(spacing: 0) {
        VStack {
            Text("Scrollable")
                .bold()
                .padding()
                .zIndex(1)

            LuminareSidebar {
                ForEach(0..<100) { num in
                    Text("\(num)")
                        .frame(width: 150, height: 40)
                        .modifier(LuminareBordered())
                }
            }
        }

        Divider()

        VStack {
            Text("Static")
                .bold()
                .padding()
                .zIndex(1)

            LuminareSidebar {
                ForEach(0..<5) { num in
                    Text("\(num)")
                        .frame(width: 150, height: 40)
                        .modifier(LuminareBordered())
                }
            }
        }
    }
    .frame(height: 420)
}
