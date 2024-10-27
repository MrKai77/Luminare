//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

public struct LuminareColorPicker<R, G, B, F>: View
where R: View, G: View, B: View, F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String {
    public typealias ColorNames = RGBColorNames<R, G, B>
    
    @Binding var currentColor: Color
    
    private let colorNames: ColorNames
    private let format: F

    @State private var text: String
    @State private var isColorPickerPresented = false

    public init(
        color: Binding<Color>,
        colorNames: ColorNames,
        format: F
    ) {
        self._currentColor = color
        self._text = State(initialValue: color.wrappedValue.toHex())
        self.colorNames = colorNames
        self.format = format
    }
    
    public init(
        color: Binding<Color>,
        colorNames: ColorNames,
        parseStrategy: StringFormatStyle.Strategy = .hex(.lowercasedWithWell)
    ) where F == StringFormatStyle {
        self.init(
            color: color,
            colorNames: colorNames,
            format: .init(parseStrategy: parseStrategy)
        )
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
                ColorPickerModalView(color: $currentColor, hexColor: $text, colorNames: colorNames)
                    .frame(width: 280)
            }
        }
        .onChange(of: currentColor) { _ in
            text = currentColor.toHex()
        }
    }
}

// preview this as app to show the modal panel
#Preview {
    LuminareColorPicker(
        color: .constant(.accentColor),
        colorNames: (
            red: Text("Red"),
            green: Text("Green"),
            blue: Text("Blue")
        ),
        parseStrategy: .hex(.custom(true, "$"))
    )
    .monospaced()
    .padding()
}
