//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

/// The style of a ``LuminareColorPicker``.
public struct LuminareColorPickerStyle<F, R, G, B, Done>
where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String,
      R: View, G: View, B: View, Done: View {
    public typealias ColorNames = RGBColorNames<R, G, B>

    struct ModalData {
        var colorNames: ColorNames
        @ViewBuilder var done: () -> Done
    }

    let format: F?
    let colorNamesAndDone: ModalData?

    /// Has a color well that can present a color picker modal.
    ///
    /// - Parameters:
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    ///   - done: the **done** label inside the color picker modal.
    public static func colorWell(
        colorNames: ColorNames,
        @ViewBuilder done: @escaping () -> Done
    ) -> Self where F == StringFormatStyle {
        .init(format: nil, colorNamesAndDone: .init(colorNames: colorNames, done: done))
    }

    /// Has a color well that can present a color picker modal, whose **done** label is a localized text.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the **done** label text.
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    public static func colorWell(
        _ key: LocalizedStringKey,
        colorNames: ColorNames
    ) -> Self where F == StringFormatStyle, Done == Text {
        .colorWell(colorNames: colorNames) {
            Text(key)
        }
    }

    /// Has a text field with a custom format.
    ///
    /// - Parameters:
    ///   - format: the `ParseableFormatStyle` to parse the color string.
    public static func textField(format: F) -> Self
    where R == EmptyView, G == EmptyView, B == EmptyView, Done == EmptyView {
        .init(format: format, colorNamesAndDone: nil)
    }

    /// Has a text field with a hex format strategy.
    ///
    /// - Parameters:
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    public static func textField(
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell)
    ) -> Self where F == StringFormatStyle, R == EmptyView, G == EmptyView, B == EmptyView, Done == EmptyView {
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
        colorNames: ColorNames,
        @ViewBuilder done: @escaping () -> Done
    ) -> Self {
        .init(format: format, colorNamesAndDone: .init(colorNames: colorNames, done: done))
    }

    /// Has both a text field with a custom format and a color well, whose **done** label is a localized text.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the **done** label text.
    ///   - format: the `ParseableFormatStyle` to parse the color string.
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    public static func textFieldWithColorWell(
        _ key: LocalizedStringKey,
        format: F,
        colorNames: ColorNames
    ) -> Self where Done == Text {
        .textFieldWithColorWell(
            format: format,
            colorNames: colorNames
        ) {
            Text(key)
        }
    }

    /// Has both a text field with a hex format strategy and a color well.
    ///
    /// - Parameters:
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    ///   - done: the **done** label inside the color picker modal.
    public static func textFieldWithColorWell(
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell),
        colorNames: ColorNames,
        @ViewBuilder done: @escaping () -> Done
    ) -> Self where F == StringFormatStyle {
        .textFieldWithColorWell(format: .init(parseStrategy: parseStrategy), colorNames: colorNames, done: done)
    }

    /// Has both a text field with a hex format strategy and a color well, whose **done** label is a localized text.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the **done** label text.
    ///   - parseStrategy: the ``StringFormatStyle/Strategy`` that specifies how the hex string will be formatted.
    ///   - colorNames: the names of the red, green, and blue color input fields inside the color picker modal.
    public static func textFieldWithColorWell(
        _ key: LocalizedStringKey,
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell),
        colorNames: ColorNames
    ) -> Self where F == StringFormatStyle, Done == Text {
        .textFieldWithColorWell(
            parseStrategy: parseStrategy,
            colorNames: colorNames
        ) {
            Text(key)
        }
    }
}

// MARK: - Color Picker

/// A stylized color picker.
public struct LuminareColorPicker<F, R, G, B, Done>: View
where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String,
      R: View, G: View, B: View, Done: View {
    public typealias Style = LuminareColorPickerStyle<F, R, G, B, Done>

    // MARK: Fields

    @Binding var currentColor: Color

    private let isBordered: Bool
    private let style: Style

    @State private var text: String
    @State private var isColorPickerPresented = false

    // MARK: Initializers

    /// Initializes a ``LuminareColorPicker``.
    ///
    /// - Parameters:
    ///   - color: the color to be edited.
    ///   - isBordered: whether to display a border around the text field while not hovering.
    ///   - style: the ``LuminareColorPickerStyle`` that defines the style of the color picker.
    public init(
        color: Binding<Color>,
        isBordered: Bool = true,
        style: Style
    ) {
        self._currentColor = color
        self._text = State(initialValue: color.wrappedValue.toHex())
        self.isBordered = isBordered
        self.style = style
    }

    // MARK: Body

    public var body: some View {
        HStack {
            if let format = style.format {
                LuminareTextField(
                    "Hex Color",
                    value: .init($text),
                    format: format,
                    isBordered: isBordered
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

            if let colorNamesAndDone = style.colorNamesAndDone {
                Button {
                    isColorPickerPresented.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(currentColor)
                        .frame(width: 26, height: 26)
                        .padding(4)
                        .modifier(LuminareBordered())
                }
                .buttonStyle(PlainButtonStyle())
                .luminareModal(isPresented: $isColorPickerPresented, closesOnDefocus: true, isCompact: true) {
                    ColorPickerModalView(
                        selectedColor: $currentColor.hsb,
                        hexColor: $text,
                        colorNames: colorNamesAndDone.colorNames,
                        done: colorNamesAndDone.done
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
            "Done",
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
