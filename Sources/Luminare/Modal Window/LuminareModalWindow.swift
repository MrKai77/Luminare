//
//  LuminareModalWindow.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-14.
//
//  Huge thanks to https://cindori.com/developer/floating-panel :)

import SwiftUI

class LuminareModalWindow<Content>: NSWindow, ObservableObject where Content: View {
    @Binding private var isPresented: Bool

    private let closesOnDefocus: Bool
    private let presentation: LuminareSheetPresentation

    private var view: NSView?
    private let initializedDate = Date.now

    init(
        isPresented: Binding<Bool>,
        isMovableByWindowBackground: Bool = false,
        closesOnDefocus: Bool = false,
        presentation: LuminareSheetPresentation,
        cornerRadii: RectangleCornerRadii,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.closesOnDefocus = closesOnDefocus
        self.presentation = presentation

        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let view = NSHostingView(
            rootView: LuminareModalView(content: content)
                .luminareSheetCornerRadii(cornerRadii)
                .environmentObject(self)
        )
        self.view = view

        self.isMovableByWindowBackground = isMovableByWindowBackground
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

        DispatchQueue.main.async {
            self.display()
            self.updatePosition()
        }
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

    func setSize(_ size: CGSize) {
        let newSize = CGSize(
            width: size.width,
            height: size.height
        )
        let newOrigin = NSPoint(
            x: frame.origin.x,
            y: frame.origin.y - (size.height - frame.height)
        )

        if Date.now.timeIntervalSince(initializedDate) < 1.0 || (newSize.width >= frame.width && newSize.height >= frame.height) {
            setFrame(.init(origin: newOrigin, size: newSize), display: false)
            return
        }

        updateShadow(for: 0.25)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            animator().setFrame(.init(origin: newOrigin, size: newSize), display: false)
        }
    }

    private func updatePosition() {
        setFrameOrigin(presentation.origin(of: frame))
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

    override func mouseDown(with event: NSEvent) {
        let titlebarHeight: CGFloat = 24
        if event.locationInWindow.y > frame.height - titlebarHeight {
            super.performDrag(with: event)
        } else {
            super.mouseDragged(with: event)
        }
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
