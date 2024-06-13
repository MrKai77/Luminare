//
//  RGBInputField.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// Custom input field for RGB values
struct RGBInputField: View {
    var label: LocalizedStringKey
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
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
