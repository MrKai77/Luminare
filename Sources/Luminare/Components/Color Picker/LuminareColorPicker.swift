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

    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareIsInsideSection) private var isInsideSection

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
        HStack(spacing: 4) {
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
                .monospaced()
                .luminareFilledStates(.none)
                .luminareBorderedStates(.none)
            }

            if style.hasColorWell {
                Button {
                    isColorPickerPresented.toggle()
                } label: {
                    UnevenRoundedRectangle(
                        topLeadingRadius: max(cornerRadii.topLeading - 4 - (isInsideSection ? 4 : 0), 2),
                        bottomLeadingRadius: max(cornerRadii.topLeading - 4 - (isInsideSection ? 4 : 0), 2),
                        bottomTrailingRadius: max(cornerRadii.topLeading - 4 - (isInsideSection ? 4 : 0), 2),
                        topTrailingRadius: max(cornerRadii.topLeading - 4 - (isInsideSection ? 4 : 0), 2)
                    )
                    .foregroundStyle(color)
                    .padding(4)
                }
                .luminareContentSize(
                    aspectRatio: 1.0,
                    contentMode: .fit,
                    hasFixedHeight: true
                )
                .luminareRoundingBehavior(
                    topLeading: true,
                    topTrailing: true,
                    bottomLeading: true,
                    bottomTrailing: true
                )
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
        .buttonStyle(.luminare)
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
    @Previewable @State var color = Color.accentColor

    LuminareSection {
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
                .monospaced(false)
        }
    }
    .monospaced()
    .frame(width: 300)
    .padding()
}
