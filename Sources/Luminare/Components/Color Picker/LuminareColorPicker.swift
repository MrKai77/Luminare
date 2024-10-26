//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

public struct LuminareColorPicker<F>: View
where F: ParseableFormatStyle, F.FormatInput == String, F.FormatOutput == String {
    @Binding var currentColor: Color

    @State private var text: String
    @State private var showColorPicker = false
    private let colorNames: (red: LocalizedStringKey, green: LocalizedStringKey, blue: LocalizedStringKey)
    private let format: F

    public init(
        color: Binding<Color>, 
        colorNames: (red: LocalizedStringKey, green: LocalizedStringKey, blue: LocalizedStringKey),
        format: F
    ) {
        self._currentColor = color
        self._text = State(initialValue: color.wrappedValue.toHex())
        self.colorNames = colorNames
        self.format = format
    }
    
    public init(
        color: Binding<Color>,
        colorNames: (red: LocalizedStringKey, green: LocalizedStringKey, blue: LocalizedStringKey),
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
                showColorPicker.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(currentColor)
                    .frame(width: 26, height: 26)
                    .padding(4)
                    .modifier(LuminareBordered())
            }
            .buttonStyle(PlainButtonStyle())
            .luminareModal(isPresented: $showColorPicker, closeOnDefocus: true, isCompact: true) {
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
            red: .init("Red"),
            green: .init("Green"),
            blue: .init("Blue")
        ),
        parseStrategy: .hex(.custom(true, "$"))
    )
    .monospaced()
    .padding()
}
