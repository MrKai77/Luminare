//
//  LuminareModalView.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

struct LuminareModalView<Content>: View where Content: View {
    @Environment(\.tintColor) var tintColor

    let sectionSpacing: CGFloat
    let outerPadding: CGFloat

    let content: Content
    let modalWindow: LuminareModal<Content>

    init(_ content: Content, _ modalWindow: LuminareModal<Content>, compactMode: Bool) {
        self.content = content
        self.modalWindow = modalWindow

        sectionSpacing = compactMode ? 8 : 16
        outerPadding = compactMode ? 8 : 16
    }

    var body: some View {
        VStack {
            VStack(spacing: self.sectionSpacing) {
                self.content
            }
            .padding(outerPadding)
            .fixedSize()
            .background {
                VisualEffectView(
                    material: .fullScreenUI,
                    blendingMode: .behindWindow
                )
                .overlay {
                    // The bottom has a smaller corner radius because a compact button will be used there
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12 + outerPadding,
                        bottomLeadingRadius: 8 + outerPadding,
                        bottomTrailingRadius: 8 + outerPadding,
                        topTrailingRadius: 12 + outerPadding
                    )
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12 + outerPadding,
                    bottomLeadingRadius: 8 + outerPadding,
                    bottomTrailingRadius: 8 + outerPadding,
                    topTrailingRadius: 12 + outerPadding
                )
            )

            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onChange(of: proxy.size) { _ in
                            let newSize = proxy.size
                            modalWindow.updateShadow(for: 0.5)
                        }
                }
            }

            Spacer()
        }
        .buttonStyle(LuminareButtonStyle())
        .tint(tintColor())
        .ignoresSafeArea()
    }
}
