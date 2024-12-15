//
//  LuminareTrafficLightedWindowView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-06-15.
//

import SwiftUI

struct LuminareTrafficLightedWindowView<Content>: View where Content: View {
    @EnvironmentObject private var floatingPanel: LuminareTrafficLightedWindow<Content>

    let sectionSpacing: CGFloat = 12
    let cornerRadius: CGFloat = 12

    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            VStack(spacing: sectionSpacing) {
                content()
            }
            .padding(.top, 40) // titlebar
            .fixedSize()
            .background {
                VisualEffectView(
                    material: .menu,
                    blendingMode: .behindWindow
                )
            }
            .overlay {
                // the bottom has a smaller corner radius because a compact button will be used there
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 8 + cornerRadius,
                    bottomTrailingRadius: 8 + cornerRadius,
                    topTrailingRadius: cornerRadius
                )
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 8 + cornerRadius,
                    bottomTrailingRadius: 8 + cornerRadius,
                    topTrailingRadius: cornerRadius
                )
            )

            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onChange(of: proxy.size) { _ in
                            floatingPanel.updateShadow(for: 0.5)
                        }
                }
            }

            Spacer()
        }
        .buttonStyle(.luminare)
        .ignoresSafeArea()
    }
}
