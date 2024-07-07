//
//  LuminareModalView.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

struct LuminareModalView<Content>: View where Content: View {
    @Environment(\.tintColor) var tintColor
    @EnvironmentObject var floatingPanel: LuminareModal<Content>

    @State var isFullyOpen: Bool = false

    var sectionSpacing: CGFloat
    var outerPadding: CGFloat
    @ViewBuilder var content: () -> Content

    init(isCompact: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.sectionSpacing = isCompact ? 8 : 16
        self.outerPadding = isCompact ? 8 : 16
        self.content = content
    }

    var body: some View {
        VStack {
            VStack(spacing: sectionSpacing) {
                content()
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
                            guard let modalWindow = floatingPanel as? LuminareModal<Content> else { return }
                            modalWindow.updateShadow(for: 0.5)
                        }
                }
            }

            Spacer()
        }
        .buttonStyle(LuminareButtonStyle())
        .tint(tintColor())
        .ignoresSafeArea()

        .scaleEffect(isFullyOpen ? 1 : 0.1)
        .blur(radius: isFullyOpen ? 0 : 10)
        .opacity(isFullyOpen ? 1 : 0)
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(LuminareSettingsWindow.animation) {
                    self.isFullyOpen = true
                }
                floatingPanel.center()
            }
        }
    }
}
