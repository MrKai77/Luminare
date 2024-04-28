//
//  LuminareModalView.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

struct LuminareModalView<Content>: View where Content: View {
    @Environment(\.tintColor) var tintColor

    let sectionSpacing: CGFloat = 16

    let content: Content
    let modalWindow: LuminareModal<Content>

    init(_ content: Content, _ modalWindow: LuminareModal<Content>) {
        self.content = content
        self.modalWindow = modalWindow
    }

    var body: some View {
        VStack {
            VStack(spacing: self.sectionSpacing) {
                self.content
            }
            .padding(16)
            .frame(width: 400)
            .fixedSize()
            .background {
                VisualEffectView(
                    material: .fullScreenUI,
                    blendingMode: .behindWindow
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                }
            }
            .clipShape(.rect(cornerRadius: 28, style: .continuous))

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
        .toggleStyle(.switch)
        .tint(tintColor)
        .ignoresSafeArea()
    }
}
