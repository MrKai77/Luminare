//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

public struct LuminareColorPicker<R, G, B, F, Done>: View
where R: View, G: View, B: View, F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String, Done: View {
    public typealias ColorNames = RGBColorNames<R, G, B>
    
    @Binding var currentColor: Color
    
    private let colorNames: ColorNames
    private let format: F
    
    @ViewBuilder private let done: () -> Done

    @State private var text: String
    @State private var isColorPickerPresented = false

    public init(
        color: Binding<Color>,
        colorNames: ColorNames,
        format: F,
        @ViewBuilder done: @escaping () -> Done
    ) {
        self._currentColor = color
        self._text = State(initialValue: color.wrappedValue.toHex())
        self.colorNames = colorNames
        self.format = format
        self.done = done
    }
    
    public init(
        color: Binding<Color>,
        colorNames: ColorNames,
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell),
        @ViewBuilder done: @escaping () -> Done
    ) where F == StringFormatStyle {
        self.init(
            color: color,
            colorNames: colorNames,
            format: .init(parseStrategy: parseStrategy),
            done: done
        )
    }
    
    public init(
        _ key: LocalizedStringKey,
        color: Binding<Color>,
        colorNames: ColorNames,
        format: F
    ) where Done == Text {
        self.init(
            color: color,
            colorNames: colorNames,
            format: format
        ) {
            Text(key)
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        color: Binding<Color>,
        colorNames: ColorNames,
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell)
    ) where F == StringFormatStyle, Done == Text {
        self.init(
            color: color,
            colorNames: colorNames,
            parseStrategy: parseStrategy
        ) {
            Text(key)
        }
    }

    public var body: some View {
        HStack {
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
            .modifier(LuminareBordered())

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
            .luminareModal(isPresented: $isColorPickerPresented, closeOnDefocus: true, isCompact: true) {
                ColorPickerModalView(
                    color: $currentColor,
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

private struct ColorPickerPreview<F>: View
where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String {
    let format: F
    @State var color: Color = .accentColor
    
    var body: some View {
        LuminareColorPicker(
            "Done",
            color: $color,
            colorNames: (
                red: Text("Red"),
                green: Text("Green"),
                blue: Text("Blue")
            ),
            format: format
        )
    }
}

// preview as app
#Preview {
    ColorPickerPreview(format: StringFormatStyle(parseStrategy: .hex(.custom(true, "$"))))
    .monospaced()
    .padding()
}
