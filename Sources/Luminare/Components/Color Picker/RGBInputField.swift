//
//  RGBInputField.swift
//  Luminare
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// MARK: - RGB Input Field

struct RGBInputField<Label>: View where Label: View {
    // MARK: Fields

    @Binding var value: Double // [0, 255]
    @ViewBuilder var label: () -> Label
    var color: (Double) -> Color? = { _ in nil }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            label()
                .foregroundStyle(.secondary)

            if #available(macOS 15.0, *) {
                LuminareTextField(
                    "", value: .init($value),
                    format: .number.precision(.integerAndFractionLength(
                        integerLimits: 1...3,
                        fractionLimits: 0...2
                    ))
                )
                .luminareToolTip(arrowEdge: .top) {
                    LuminareStepper(
                        value: $value,
                        source: .finiteContinuous(in: 0...255, step: 5),
                        indicatorSpacing: 20,
                        prominentIndicators: .init(color: color)
                    )
                    .frame(width: 135, height: 32)
                    .padding(.vertical, 2)
                    .luminareTint(overridingWith: .primary)
                }
                .luminareToolTipTrigger(.forceTouch())
            } else {
                LuminareTextField(
                    "", value: .init($value),
                    format: .number.precision(.integerAndFractionLength(
                        integerLimits: 1...3,
                        fractionLimits: 0...2
                    ))
                )
            }
        }
    }
}

// MARK: - Previews

@available(macOS 15.0, *)
#Preview("RGBInputField") {
    @Previewable @State var value: Double = 42

    LuminareSection {
        RGBInputField(value: $value) {
            Text("Red")
        } color: { value in
            .init(red: value / 255.0, green: 0, blue: 0)
        }
    }
    .padding()
}
