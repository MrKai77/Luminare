//
//  LuminareModalWindow.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public class LuminareModalWindow<Content> where Content: View {
    var windowController: NSWindowController?
    var content: Content
    var tint: Color

    let sectionSpacing: CGFloat = 16

    public init(tint: Color = .accentColor, _ content: Content) {
        self.tint = tint
        self.content = content
    }

    public func show() {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }

        let view = NSHostingView(
            rootView: VStack {
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
                                self.updateShadow(for: 0.5)
                            }
                    }
                }

                Spacer()
            }
            .buttonStyle(LuminareButtonStyle())
            .toggleStyle(.switch)
            .tint(self.tint)
            .environment(\.tintColor, self.tint)
            .ignoresSafeArea()
        )

        let window = LuminareModalNSWindow(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.backgroundColor = .clear
        window.contentView = view
        window.contentView?.wantsLayer = true

        window.ignoresMouseEvents = false
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.hasShadow = true

        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        window.animationBehavior = .documentWindow
        window.center()
        window.orderFrontRegardless()

        self.windowController = .init(window: window)
    }

    func updateShadow(for duration: Double) {
        guard let window = windowController?.window else { return }

        let frameRate: Double = 60
        let interval = 1 / frameRate

        for i in 0...Int(duration * Double(frameRate)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                window.invalidateShadow()
            }
        }
    }
}

class LuminareModalNSWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        let wKey = 13
        if event.keyCode == wKey && event.modifierFlags.contains(.command) {
            self.close()
        }
    }
}
