//
//  LuminareTextField.swift
//
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

// MARK: - Text Field

/// A stylized text field.
public struct LuminareTextField<F>: View where F: ParseableFormatStyle, F.FormatOutput == String {
    // MARK: Fields

    @Binding private var value: F.FormatInput?
    private let format: F
    private let placeholder: LocalizedStringKey

    @State private var monitor: Any?

    // MARK: Initializers

    /// Initializes a ``LuminareTextField``.
    ///
    /// - Parameters:
    ///   - placeholder: the `LocalizedStringKey` to look up the placeholder text.
    ///   - value: the value to be edited.
    ///   - format: the format of the value.
    public init(
        _ placeholder: LocalizedStringKey,
        value: Binding<F.FormatInput?>, format: F
    ) {
        self._value = value
        self.format = format
        self.placeholder = placeholder
    }

    /// Initializes a ``LuminareTextField`` with a `String` value.
    ///
    /// - Parameters:
    ///   - placeholder: the `LocalizedStringKey` to look up the placeholder text.
    ///   - value: the `String` value to be edited.
    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String?>
    ) where F == StringFormatStyle {
        self.init(
            placeholder,
            value: text, format: StringFormatStyle()
        )
    }

    // MARK: Body

    public var body: some View {
        TextField(placeholder, value: $value, format: format)
            .textFieldStyle(.plain)
            .modifier(LuminareHoverable())

            .onAppear {
                guard monitor != nil else { return }

                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if let window = NSApp.keyWindow, window.animationBehavior == .documentWindow {
                        window.keyDown(with: event)

                        // fixes cmd+w to close window.
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

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareTextField",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        VStack {
            LuminareTextField("Text Field", text: .constant("Bordered"))

            LuminareTextField("Text Field", text: .constant("Borderless"))
                .luminareBordered(false)

            LuminareTextField("Text Field", text: .constant("Disabled"))
                .disabled(true)
        }
    }
    .luminareCompactButtonAspectRatio(contentMode: .fill)
}
