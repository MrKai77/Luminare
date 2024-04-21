//
//  LuminareModalWindowController.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

class LuminareModalWindowController: NSWindowController {
    let didCloseHandler: () -> Void

    init(window: NSWindow?, didCloseHandler: @escaping () -> Void) {
        self.didCloseHandler = didCloseHandler
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func keyDown(with event: NSEvent) {
        let wKey = 13
        if event.keyCode == wKey && event.modifierFlags.contains(.command) {
            self.close()
        }
    }

    override func close() {
        if let window = self.window {
            NSAnimationContext.runAnimationGroup({ context -> Void in
                context.duration = 0.1
                window.animator().alphaValue = 0
            }, completionHandler: {
                super.close()
                self.didCloseHandler()
            })
        } else {
            super.close()
            self.didCloseHandler()
        }
    }
}
