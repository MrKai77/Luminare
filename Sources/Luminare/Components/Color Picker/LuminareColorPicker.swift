//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

/// The style of a ``LuminareColorPicker``.
public struct LuminareColorPickerStyle<F, R, G, B>
    where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String,
          R: View, G: View, B: View {
    public typealias ColorNames = RGBColorNames<R, G, B>
    
    let format: F?
    let colorNames: ColorNames?
    
    /// Has a color well that can present a color picker modal.
    ///
    /// - Parameters:
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    ///   - done: the **done** label inside the color picker modal.
    public static func colorWell(
        colorNames: ColorNames
    ) -> Self where F == StringFormatStyle {
        .init(format: nil, colorNames: colorNames)
    }
    
    /// Has a text field with a custom format.
    ///
    /// - Parameters:
    ///   - format: the `ParseableFormatStyle` to parse the color string.
    public static func textField(format: F) -> Self
    where R == EmptyView, G == EmptyView, B == EmptyView {
        .init(format: format, colorNames: nil)
    }
    
    /// Has a text field with a hex format strategy.
    ///
    /// - Parameters:
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    public static func textField(
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell)
    ) -> Self where F == StringFormatStyle, R == EmptyView, G == EmptyView, B == EmptyView {
        .textField(format: .init(parseStrategy: parseStrategy))
    }
    
    /// Has both a text field with a custom format and a color well.
    ///
    /// - Parameters:
    ///   - format: the `ParseableFormatStyle` to parse the color string.
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    ///   - done: the **done** label inside the color picker modal.
    public static func textFieldWithColorWell(
        format: F,
        colorNames: ColorNames
    ) -> Self {
        .init(format: format, colorNames: colorNames)
    }
    
    /// Has both a text field with a hex format strategy and a color well.
    ///
    /// - Parameters:
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    ///   - done: the **done** label inside the color picker modal.
    public static func textFieldWithColorWell(
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell),
        colorNames: ColorNames
    ) -> Self where F == StringFormatStyle {
        .textFieldWithColorWell(format: .init(parseStrategy: parseStrategy), colorNames: colorNames)
    }
}

// MARK: - Color Picker

/// A stylized color picker.
public struct LuminareColorPicker<F, R, G, B>: View
    where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String,
    R: View, G: View, B: View {
    public typealias Style = LuminareColorPickerStyle<F, R, G, B>

    // MARK: Fields

    @Binding var currentColor: Color

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
        self._currentColor = color
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
                        currentColor = newColor
                        text = newColor.toHex()
                    } else {
                        // revert to last valid color
                        text = currentColor.toHex()
                    }
                }
            }

            if let colorNames = style.colorNames {
                Button {
                    isColorPickerPresented.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(currentColor)
                        .frame(width: 26, height: 26)
                        .padding(4)
                        .modifier(LuminareBordered())
                }
                .buttonStyle(.plain)
                .luminareModal(isPresented: $isColorPickerPresented, closesOnDefocus: true, isCompact: true) {
                    ColorPickerModalView(
                        selectedColor: $currentColor.hsb,
                        hexColor: $text,
                        colorNames: colorNames
                    )
                    .frame(width: 280)
                }
            }
        }
        .onChange(of: currentColor) { _ in
            text = currentColor.toHex()
        }
    }
}

// MARK: - Previews

// preview as app
@available(macOS 15.0, *)
#Preview(
    "LuminareColorPicker",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var color: Color = .accentColor

    LuminareColorPicker(
        color: $color,
        style: .textFieldWithColorWell(
            colorNames: .init {
                Text("Red")
            } green: {
                Text("Green")
            } blue: {
                Text("Blue")
            }
        )
    )
    .monospaced()
    .frame(width: 300)
}
