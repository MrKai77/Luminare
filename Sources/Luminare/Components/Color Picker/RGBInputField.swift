//
//  RGBInputField.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// custom input field for RGB values
struct RGBInputField<Label>: View where Label: View {
    @Binding var value: Double
    @ViewBuilder let label: () -> Label

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            label()
                .foregroundStyle(.secondary)

            Color.clear
                .frame(height: 34)
                .overlay {
                    TextField("", value: $value, formatter: NumberFormatter())
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                }
                .background(.quinary.opacity(0.5))
                .clipShape(.rect(cornerRadius: 8))
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.quaternary.opacity(0.5), lineWidth: 1)
                }
        }
    }
}

#Preview {
    LuminareSection {
        RGBInputField(value: .constant(42.0)) {
            Text("Red")
        }
    }
    .padding()
}
