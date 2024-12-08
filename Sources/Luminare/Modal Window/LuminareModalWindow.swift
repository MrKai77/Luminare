//
//  LuminareModalWindow.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//
//  Huge thanks to https://cindori.com/developer/floating-panel :)

import SwiftUI

class LuminareModal<Content>: NSWindow, ObservableObject where Content: View {
    @Binding private var isPresented: Bool

    private let closesOnDefocus: Bool

    init(
        isPresented: Binding<Bool>,
        isMovableByWindowBackground: Bool = false,
        closesOnDefocus: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.closesOnDefocus = closesOnDefocus
        
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let hostingView = NSHostingView(
            rootView: LuminareModalView(content: content)
                .environmentObject(self)
        )

        self.isMovableByWindowBackground = isMovableByWindowBackground
        collectionBehavior.insert(.fullScreenAuxiliary)
        level = .floating
        backgroundColor = .clear
        contentView = hostingView
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
        let updatesCount = Int(duration * frameRate)
        let interval = duration / Double(updatesCount)

        for index in 0...updatesCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * interval) {
                self.invalidateShadow()
            }
        }
    }

    override func close() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            self.animator().alphaValue = 0
        }, completionHandler: {
            super.close()
            self.isPresented = false
        })
    }

    override func keyDown(with event: NSEvent) {
        let wKey = 13
        if event.keyCode == wKey, event.modifierFlags.contains(.command) {
            close()
            return
        }
        super.keyDown(with: event)
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    override func resignMain() {
        if closesOnDefocus {
            close()
        }
    }
}

struct LuminareModalModifier<PanelContent>: ViewModifier where PanelContent: View {
    @State private var panel: LuminareModal<PanelContent>?

    @Binding var isPresented: Bool
    var isMovableByWindowBackground: Bool = false
    var closesOnDefocus: Bool = false
    @ViewBuilder var content: () -> PanelContent

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    present()
                } else {
                    close()
                }
            }
            .onDisappear {
                isPresented = false
                close()
            }
    }

    private func present() {
        guard panel == nil else { return }
        panel = LuminareModal(
            isPresented: $isPresented,
            isMovableByWindowBackground: isMovableByWindowBackground,
            closesOnDefocus: closesOnDefocus,
            content: content
        )

        DispatchQueue.main.async {
            panel?.center()
            panel?.orderFrontRegardless()
            panel?.makeKey()
        }
    }

    private func close() {
        panel?.close()
        panel = nil
    }
}
