//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

public struct LuminareColorPicker: View {
    @Binding var currentColor: Color

    @State private var color: Color
    @State private var text: String

    @State private var showColorPicker = false

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
                    if let newColor = Color(hex: text) {
                        text = newColor.toHex()
                        withAnimation(.smooth(duration: 0.3)) {
                            color = newColor
                        }
                    } else {
                        text = color.toHex()    // revert to last color
                    }
                }
            )
            .modifier(LuminareBordered())

            Button {
                showColorPicker.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(self.color)
                    .frame(width: 26, height: 26)
                    .padding(4)
                    .modifier(LuminareBordered())
            }
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $showColorPicker) {
                ColorPickerPopover(color: $color, hexColor: $text)
            }
        }
        .onChange(of: color) { _ in
            currentColor = color
        }
    }
}
