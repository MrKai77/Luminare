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

    @State var isShown = false
    let content: Content
    let modalWindow: LuminareModalWindow<Content>

    init(_ content: Content, _ modalWindow: LuminareModalWindow<Content>) {
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
        .scaleEffect(self.isShown ? 1 : 0.5)
        .opacity(self.isShown ? 1 : 0)
        .onAppear {
            DispatchQueue.main.async {
                modalWindow.updateShadow(for: 0.5)
                withAnimation(.smooth(duration: 0.3)) {
                    self.isShown = true
                }
            }
        }
    }
}
