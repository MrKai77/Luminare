//
//  LuminareModalWindow.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//
// Huge thanks to https://cindori.com/developer/floating-panel :)

import SwiftUI

struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSWindow? = nil
}

extension EnvironmentValues {
  var floatingPanel: NSWindow? {
    get { self[FloatingPanelKey.self] }
    set { self[FloatingPanelKey.self] = newValue }
  }
}

class LuminareModal<Content>: NSWindow where Content: View {
    @Binding var isPresented: Bool

    init(
        view: () -> Content,
        isPresented: Binding<Bool>
    ) {
        self._isPresented = isPresented

        super.init(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let view = NSHostingView(
            rootView: LuminareModalView(view(), self)
                .environment(\.floatingPanel, self)
                .environment(\.tintColor, LuminareSettingsWindow.tint)
        )

        collectionBehavior.insert(.fullScreenAuxiliary)
        level = .floating

        backgroundColor = .clear
        contentView = view
        contentView?.wantsLayer = true

        ignoresMouseEvents = false
        isOpaque = false
        hasShadow = true

        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        animationBehavior = .documentWindow

        center()
    }

    func updateShadow(for duration: Double) {
        guard isPresented else { return }

        let frameRate: Double = 60
        let interval = 1 / frameRate

        for i in 0...Int(duration * Double(frameRate)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                self.invalidateShadow()
            }
        }
    }

    override func close() {
        NSAnimationContext.runAnimationGroup({ context -> Void in
            context.duration = 0.15
            self.animator().alphaValue = 0
        }, completionHandler: {
            super.close()
        })

        self.isPresented = false
    }

    override func keyDown(with event: NSEvent) {
        let wKey = 13
        if event.keyCode == wKey && event.modifierFlags.contains(.command) {
            close()
        }

        super.keyDown(with: event)
    }
}

struct LuminareModalModifier<PanelContent>: ViewModifier where PanelContent: View {
    @Binding var isPresented: Bool
    @ViewBuilder let view: () -> PanelContent
    @State var panel: LuminareModal<PanelContent>?

    init(isPresented: Binding<Bool>, view: @escaping () -> PanelContent) {
        self._isPresented = isPresented
        self.view = view
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                if isPresented {
                    present()
                }
            }
            .onDisappear {
                close()
            }
            .onChange(of: isPresented) { _ in
                if isPresented {
                    present()
                } else {
                    close()
                }
            }
    }

    func present() {
        DispatchQueue.main.async {
            self.panel = LuminareModal(
                view: view,
                isPresented: $isPresented
            )

            self.panel?.orderFrontRegardless()
            self.panel?.makeKey()
        }
    }

    func close() {
        panel?.close()
        panel = nil
    }
}

extension View {
    public func luminareModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(LuminareModalModifier(isPresented: isPresented, view: content))
    }
}
