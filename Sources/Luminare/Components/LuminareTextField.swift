//
//  LuminareTextField.swift
//  Luminare
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

    private let id = UUID()

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
                EventMonitorManager.shared.addLocalMonitor(
                    for: id,
                    matching: .keyDown
                ) { event in
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
                EventMonitorManager.shared.removeMonitor(for: id)
            }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareTextField",
    traits: .sizeThatFitsLayout
) {
    @Previewable @FocusState var isFocused: Bool

    LuminareSection {
        VStack {
            LuminareTextField("Text Field", text: .constant("Bordered"))
                .focused($isFocused)

            LuminareTextField("Text Field", text: .constant("Borderless"))
                .luminareBordered(false)
                .focused($isFocused)

            LuminareTextField("Text Field", text: .constant("Disabled"))
                .disabled(true)
                .focused($isFocused)
        }
        .onAppear {
            isFocused = false
        }
    }
    .luminareAspectRatio(contentMode: .fill)
}
