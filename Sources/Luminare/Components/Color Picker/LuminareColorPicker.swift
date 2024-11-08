//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

// MARK: - Color Picker

/// A stylized color picker.
public struct LuminareColorPicker<R, G, B, F, Done>: View
where R: View, G: View, B: View,
        F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String,
        Done: View {
    public typealias ColorNames = RGBColorNames<R, G, B>

    // MARK: Fields

    @Binding var currentColor: Color

    private let format: F
    private let isBordered: Bool
    private let colorNames: ColorNames

    @ViewBuilder private let done: () -> Done

    @State private var text: String
    @State private var isColorPickerPresented = false

    // MARK: Initializers

    /// The most flexible option to initialize a ``LuminareColorPicker``.
    /// - Parameters:
    ///   - color: the color to be edited.
    ///   - format: the format of the hex color.
    ///   - isBordered: whether the text field should be bordered.
    ///   - colorNames: names for the RGB components. Used for localization.
    ///   - done: view to be displayed in the modal's done button.
    public init(
        color: Binding<Color>,
        format: F,
        isBordered: Bool = true,
        colorNames: ColorNames,
        @ViewBuilder done: @escaping () -> Done
    ) {
        self._currentColor = color
        self._text = State(initialValue: color.wrappedValue.toHex())
        self.format = format
        self.isBordered = isBordered
        self.colorNames = colorNames
        self.done = done
    }

    /// Initialize a ``LuminareColorPicker`` using preset hex color strategies.
    /// - Parameters:
    ///   - color: the color to be edited.
    ///   - parseStrategy: the strategy used to parse the hex color.
    ///   - isBordered: whether the text field should be bordered.
    ///   - colorNames: names for the RGB components. Used for localization.
    ///   - done: view to be displayed in the modal's done button.
    public init(
        color: Binding<Color>,
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell),
        isBordered: Bool = true,
        colorNames: ColorNames,
        @ViewBuilder done: @escaping () -> Done
    ) where F == StringFormatStyle {
        self.init(
            color: color,
            format: .init(parseStrategy: parseStrategy),
            isBordered: isBordered,
            colorNames: colorNames,
            done: done
        )
    }

    /// Initialize a ``LuminareColorPicker`` using a custom hex color format strategy.
    /// - Parameters:
    ///   - key: the key for the localized string of the done button.
    ///   - color: the color to be edited.
    ///   - format: the format of the hex color.
    ///   - isBordered: whether the text field should be bordered.
    ///   - colorNames: names for the RGB components. Used for localization.
    public init(
        _ key: LocalizedStringKey,
        color: Binding<Color>,
        format: F,
        isBordered: Bool = true,
        colorNames: ColorNames
    ) where Done == Text {
        self.init(
            color: color,
            format: format,
            isBordered: isBordered,
            colorNames: colorNames
        ) {
            Text(key)
        }
    }

    /// Initialize a ``LuminareColorPicker`` using preset hex color strategies.
    /// - Parameters:
    ///   - key: the key for the localized string of the done button.
    ///   - color: the color to be edited.
    ///   - parseStrategy: the strategy used to parse the hex color.
    ///   - isBordered: whether the text field should be bordered.
    ///   - colorNames: names for the RGB components. Used for localization.
    public init(
        _ key: LocalizedStringKey,
        color: Binding<Color>,
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell),
        isBordered: Bool = true,
        colorNames: ColorNames
    ) where F == StringFormatStyle, Done == Text {
        self.init(
            color: color,
            parseStrategy: parseStrategy,
            isBordered: isBordered,
            colorNames: colorNames
        ) {
            Text(key)
        }
    }

    // MARK: Body

    public var body: some View {
        HStack {
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
                    colorNames: colorNames,
                    done: done
                )
                .frame(width: 280)
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
        "Done",
        color: $color,
        format: StringFormatStyle(parseStrategy: .hex(.lowercasedWithWell)),
        colorNames: .init {
            Text("Red")
        } green: {
            Text("Green")
        } blue: {
            Text("Blue")
        }
    )
    .monospaced()
    .frame(width: 300)
}
