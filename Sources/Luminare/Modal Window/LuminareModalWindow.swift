//
//  LuminareModalWindow.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct DismissModalAction {
    typealias Action = () -> Void
    let action: Action

    public func callAsFunction() {
        action()
    }
}

public extension EnvironmentValues {
    var dismissModal: DismissModalAction {
        get { self[DismissModalActionKey.self] }
        set { self[DismissModalActionKey.self] = newValue }
    }
}

public struct DismissModalActionKey: EnvironmentKey {
    public static var defaultValue: DismissModalAction = .init(action: {})
}

public class LuminareModalWindow<Content> where Content: View {
    var windowController: LuminareModalWindowController?
    var content: Content
    var tint: Color

    public init(tint: Color? = nil, _ content: Content) {
        self.tint = tint ?? LuminareSettingsWindow.tint
        self.content = content
    }

    public func show() {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }

        let dismissModal: () -> Void = {
            self.windowController?.close()
        }

        let view = NSHostingView(
            rootView: LuminareModalView(self.content, self)
                .environment(\.tintColor, self.tint)
                .environment(\.dismissModal, .init(action: dismissModal))
        )

        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.backgroundColor = .clear
        window.contentView = view
        window.contentView?.wantsLayer = true

        window.ignoresMouseEvents = false
        window.isOpaque = false
        window.hasShadow = true

        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.animationBehavior = .documentWindow

        window.center()
        window.orderFrontRegardless()

        self.windowController = .init(window: window, didCloseHandler: {
            self.windowController = nil
        })
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
