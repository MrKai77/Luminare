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
    // MARK: Environments

    @Environment(\.luminareAnimationFast) private var animationFast

    private let minHeight: CGFloat, horizontalPadding: CGFloat, cornerRadius: CGFloat
    private let isBordered: Bool

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
    ///   - minHeight: the minimum height of the inner view.
    ///   - horizontalPadding: the horizontal padding of the inner view.
    ///   - cornerRadius: the radius of the corners..
    ///   - isBordered: whether to display a border while not hovering.
    public init(
        _ placeholder: LocalizedStringKey,
        value: Binding<F.FormatInput?>, format: F,
        minHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true
    ) {
        self.minHeight = minHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.isBordered = isBordered
        self._value = value
        self.format = format
        self.placeholder = placeholder
    }

    /// Initializes a ``LuminareTextField`` with a `String` value.
    ///
    /// - Parameters:
    ///   - placeholder: the `LocalizedStringKey` to look up the placeholder text.
    ///   - value: the `String` value to be edited.
    ///   - minHeight: the minimum height of the inner view.
    ///   - horizontalPadding: the horizontal padding of the inner view.
    ///   - cornerRadius: the radius of the corners..
    ///   - isBordered: whether to display a border while not hovering.
    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        minHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true
    ) where F == StringFormatStyle {
        self.init(
            placeholder,
            value: .init(text), format: StringFormatStyle(),
            minHeight: minHeight, horizontalPadding: horizontalPadding,
            cornerRadius: cornerRadius,
            isBordered: isBordered
        )
    }

    // MARK: Body

    public var body: some View {
        TextField(placeholder, value: $value, format: format)
            .textFieldStyle(.plain)
            .modifier(LuminareHoverable(
                minHeight: minHeight,
                horizontalPadding: horizontalPadding,
                cornerRadius: cornerRadius,
                isBordered: isBordered
            ))
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

            LuminareTextField("Text Field", text: .constant("Borderless"), isBordered: false)

            LuminareTextField("Text Field", text: .constant("Disabled"))
                .disabled(true)
        }
    }
}
