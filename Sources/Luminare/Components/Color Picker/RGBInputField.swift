//
//  RGBInputField.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// MARK: - RGB Inout Field

// custom input field for RGB values
struct RGBInputField<Label>: View where Label: View {
    // MARK: Fields

    @Binding var value: Double
    @ViewBuilder var label: () -> Label
    var color: (Double) -> Color? = { _ in nil }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            label()
                .foregroundStyle(.secondary)

            if #available(macOS 15.0, *) {
                LuminarePopover(arrowEdge: .top, trigger: .onForceTouch()) {
                    LuminareStepper(
                        value: .init {
                            value * 255.0
                        } set: { newValue in
                            value = newValue / 255.0
                        },
                        source: .finiteContinuous(range: 0...255, stride: 5),
                        indicatorSpacing: 20,
                        prominentIndicators: .init(color: color)
                    )
                    .frame(width: 135, height: 32)
                    .padding(.vertical, 2)
                    .environment(\.luminareTint) { .primary }
                } badge: {
                    LuminareTextField(
                        "", value: .init($value),
                        format: .number.precision(.integerAndFractionLength(
                            integerLimits: 0...3,
                            fractionLimits: 0...1)))
                }
            } else {
                LuminareTextField(
                    "", value: .init($value),
                    format: .number.precision(.integerAndFractionLength(
                        integerLimits: 0...3,
                        fractionLimits: 0...1)))
            }
        }
    }
}

// MARK: - Preview

private struct RGBInputFieldPreview: View {
    @State private var value: Double = 42

    var body: some View {
        RGBInputField(value: $value) {
            Text("Red")
        } color: { value in
                .init(red: value, green: 0, blue: 0)
        }
    }
}

#Preview("RGBInputField") {
    LuminareSection {
        RGBInputFieldPreview()
    }
    .padding()
}
