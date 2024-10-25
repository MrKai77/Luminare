//
//  LuminareTextField.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

public struct LuminareTextField<F>: View
where F: ParseableFormatStyle, F.FormatOutput == String {
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    
    @Binding var value: F.FormatInput?
    let format: F
    let placeholder: LocalizedStringKey

    @State var monitor: Any?

    public init(
        _ placeholder: LocalizedStringKey,
        value: Binding<F.FormatInput?>, format: F,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self._value = value
        self.format = format
        self.placeholder = placeholder
    }

    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8
    ) where F == StringFormatStyle {
        self.init(
            placeholder,
            value: .init(text), format: StringFormatStyle(),
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding
        )
    }

    public var body: some View {
        TextField(placeholder, value: $value, format: format)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: elementMinHeight)
            .textFieldStyle(.plain)
            .onAppear {
                guard monitor != nil else { return }

                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let window = NSApp.keyWindow, window.animationBehavior == .documentWindow {
                        window.keyDown(with: event)

                        // Fixes cmd+w to close window.
                        let wKey = 13
                        if event.keyCode == wKey, event.modifierFlags.contains(.command) {
                            return nil
                        }
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor {
                    NSEvent.removeMonitor(monitor)
                }
                monitor = nil
            }
    }
}
