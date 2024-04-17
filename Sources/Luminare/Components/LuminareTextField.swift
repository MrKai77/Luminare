//
//  LuminareTextField.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public struct LuminareTextField: View {
    let elementMinHeight: CGFloat = 34
    let horizontalPadding: CGFloat = 12

    @Binding var text: String
    let placeHolder: String

    public init(_ text: Binding<String>, placeHolder: String) {
        self._text = text
        self.placeHolder = placeHolder
    }

    public var body: some View {
        TextField(placeHolder, text: $text)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: elementMinHeight)
            .textFieldStyle(.plain)

            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let window = NSApp.keyWindow, window as? LuminareModalNSWindow != nil {
                        window.keyDown(with: event)

                        // Fixed cmd+w to close window.
                        // TODO: Find a better solution
                        let wKey = 13
                        if event.keyCode == wKey && event.modifierFlags.contains(.command) {
                            return nil
                        }
                    }
                    return event
                }
            }
    }
}
