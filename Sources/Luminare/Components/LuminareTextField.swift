//
//  LuminareTextField.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

// MARK: - Text Field

/// A stylized text field.
public struct LuminareTextField<Label, F>: View where Label: View, F: ParseableFormatStyle, F.FormatOutput == String {
    // MARK: Fields

    @Binding private var value: F.FormatInput?
    private let format: F
    private let prompt: Text?
    @ViewBuilder private var label: () -> Label

    private let id = UUID()

    // MARK: Initializers

    public init(
        value: Binding<F.FormatInput?>,
        format: F,
        prompt: Text? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._value = value
        self.format = format
        self.prompt = prompt
        self.label = label
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        value: Binding<F.FormatInput?>,
        format: F,
        prompt: Text? = nil
    ) where Label == Text {
        self.init(
            value: value,
            format: format,
            prompt: prompt
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<F.FormatInput?>,
        format: F,
        prompt: Text? = nil
    ) where Label == Text {
        self.init(
            value: value,
            format: format,
            prompt: prompt
        ) {
            Text(titleKey)
        }
    }

    public init(
        text: Binding<String?>,
        prompt: Text? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) where F == StringFormatStyle {
        self.init(
            value: text,
            format: StringFormatStyle(),
            prompt: prompt,
            label: label
        )
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        text: Binding<String?>,
        prompt: Text? = nil
    ) where Label == Text, F == StringFormatStyle {
        self.init(
            value: text,
            format: StringFormatStyle(),
            prompt: prompt
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String?>,
        prompt: Text? = nil
    ) where Label == Text, F == StringFormatStyle {
        self.init(
            value: text,
            format: StringFormatStyle(),
            prompt: prompt
        ) {
            Text(titleKey)
        }
    }

    // MARK: Body

    public var body: some View {
        TextField(value: $value, format: format, prompt: prompt, label: label)
            .textFieldStyle(.plain)
            .modifier(
                LuminareHoverableModifier(
                    fill: .quinary,
                    hovering: .quaternary,
                    pressed: .tertiary
                )
            )
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

            LuminareTextField("Text Field", text: .constant("No Border"))
                .luminareBorderedStates(.none)
                .focused($isFocused)

            LuminareTextField("Text Field", text: .constant("No Background or Border"))
                .luminareFilledStates(.none)
                .luminareBorderedStates(.none)
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
