//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

public struct LuminareColorPicker: View {
    @Binding var currentColor: Color

    @State var color: Color
    @State var text: String

    public init(color: Binding<Color>) {
        self._currentColor = color
        self._color = State(initialValue: color.wrappedValue)
        self._text = State(initialValue: color.wrappedValue.toHex())
    }

    public var body: some View {
        HStack {
            LuminareTextField(
                $text,
                placeHolder: "Hex Color",
                onSubmit: {
                    let newColor = Color(hex: text)
                    text = newColor.toHex()
                    currentColor = newColor
                    withAnimation(.smooth(duration: 0.3)) {
                        color = newColor
                    }
                }
            )
            .modifier(LuminareBordered())

            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(self.color)
                .frame(width: 26, height: 26)
                .padding(4)
                .modifier(LuminareBordered())
        }
    }
}
