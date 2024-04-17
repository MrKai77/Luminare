//
//  LuminareModalNSWindow.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

class LuminareModalNSWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        let wKey = 13
        if event.keyCode == wKey && event.modifierFlags.contains(.command) {
            self.close()
        }
    }
}
