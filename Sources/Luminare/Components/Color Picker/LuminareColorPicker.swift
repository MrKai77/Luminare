//
//  LuminareColorPicker.swift
//  Luminare
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

/// The style of a ``LuminareColorPicker``.
public struct LuminareColorPickerStyle<F>
    where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String {
    let format: F?
    let hasColorWell: Bool

    /// Has a color well that can present a color picker modal.
    public static func colorWell() -> Self where F == StringFormatStyle {
        .init(format: nil, hasColorWell: true)
    }

    /// Has a text field with a custom format.
    ///
    /// - Parameters:
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    public static func textField(
        format: F
    ) -> Self where F == StringFormatStyle {
        .init(format: format, hasColorWell: false)
    }

    /// Has a text field with a hex format strategy.
    ///
    /// - Parameters:
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    public static func textField(
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell)
    ) -> Self where F == StringFormatStyle {
        .textField(format: .init(parseStrategy: parseStrategy))
    }

    /// Has both a text field with a custom format and a color well.
    ///
    /// - Parameters:
    ///   - format: the `ParseableFormatStyle` to parse the color string.
    public static func textFieldWithColorWell(
        format: F
    ) -> Self {
        .init(format: format, hasColorWell: true)
    }

    /// Has both a text field with a hex format strategy and a color well.
    ///
    /// - Parameters:
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    public static func textFieldWithColorWell(
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell)
    ) -> Self where F == StringFormatStyle {
        .textFieldWithColorWell(format: .init(parseStrategy: parseStrategy))
    }
}

// MARK: - Color Picker

/// A stylized color picker.
public struct LuminareColorPicker<F>: View
    where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String {
    public typealias Style = LuminareColorPickerStyle<F>

    // MARK: Environments

    @Environment(\.luminareCompactButtonCornerRadii) private var cornerRadii

    // MARK: Fields

    @Binding var color: Color

    private let style: Style

    @State private var text: String
    @State private var isColorPickerPresented = false

    // MARK: Initializers

    /// Initializes a ``LuminareColorPicker``.
    ///
    /// - Parameters:
    ///   - color: the color to be edited.
    ///   - style: the ``LuminareColorPickerStyle`` that defines the style of the color picker.
    public init(
        color: Binding<Color>,
        style: Style
    ) {
        self._color = color
        self._text = State(initialValue: color.wrappedValue.toHex())
        self.style = style
    }

    // MARK: Body

    public var body: some View {
        HStack {
            if let format = style.format {
                LuminareTextField(
                    "Hex Color",
                    value: .init($text),
                    format: format
                )
                .onSubmit {
                    if let newColor = Color(hex: text) {
                        color = newColor
                        text = newColor.toHex()
                    } else {
                        // Revert to last valid color
                        text = color.toHex()
                    }
                }
            }

            if style.hasColorWell {
                Button {
                    isColorPickerPresented.toggle()
                } label: {
                    UnevenRoundedRectangle(cornerRadii: cornerRadii.map { max(0, $0 - 4) })
                        .foregroundStyle(color)
                        .padding(4)
                }
                .buttonStyle(.luminareCompact)
                .luminareHorizontalPadding(0)
                .luminareAspectRatio(1 / 1, contentMode: .fit)
                .luminareModalWithPredefinedSheetStyle(isPresented: $isColorPickerPresented) {
                    VStack {
                        ColorPickerModalView(
                            selectedColor: $color,
                            hexColor: $text
                        )
                    }
                    .frame(width: 260)
                }
            }
        }
        .onChange(of: color) { _ in
            text = color.toHex()
        }
    }
}

// MARK: - Previews

// Preview as app
@available(macOS 15.0, *)
#Preview(
    "LuminareColorPicker",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var color: Color = .accentColor

    VStack {
        LuminareColorPicker(
            color: $color,
            style: .textFieldWithColorWell()
        )

        LuminareColorPicker(
            color: $color,
            style: .textFieldWithColorWell()
        )
        .luminareModalStyle(.popover)
        .luminareModalContentWrapper { view in
            view
                .luminareAspectRatio(contentMode: .fit)
                .monospaced(false)
        }
    }
    .luminareAspectRatio(contentMode: .fill)
    .monospaced()
    .frame(width: 300)
}
