//
//  ColorPickerModalView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// View for the color popup as a whole
struct ColorPickerModalView: View {
    @Binding var color: Color
    @Binding var hexColor: String
    @State private var redComponent: Double = 0
    @State private var greenComponent: Double = 0
    @State private var blueComponent: Double = 0

    // Main view containing all components of the color picker
    var body: some View {
        Group {
            LuminareSection(disablePadding: true, showDividers: false) {
                Group {
                    ColorSaturationBrightnessView(selectedColor: $color)
                        .scaledToFill()
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 8,
                                bottomLeadingRadius: 2,
                                bottomTrailingRadius: 2,
                                topTrailingRadius: 8
                            )
                        )

                    ColorHueSliderView(selectedColor: $color)
                        .scaledToFill()
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 2,
                                bottomLeadingRadius: 8,
                                bottomTrailingRadius: 8,
                                topTrailingRadius: 2
                            )
                        )
                }
                .padding(4)
            }

            RGBInputFields
        }
        .onAppear {
            updateComponents(newValue: color)
        }
        .onChange(of: color) { _ in
            updateComponents(newValue: color)
        }
    }

    // View for RGB input fields
    private var RGBInputFields: some View {
        HStack(spacing: 8) {
            RGBInputField(label: "Red", value: $redComponent)
                .onChange(of: redComponent) { _ in
                    setColor(updateColorFromRGB())
                }

            RGBInputField(label: "Green", value: $greenComponent)
                .onChange(of: greenComponent) { _ in
                    setColor(updateColorFromRGB())
                }

            RGBInputField(label: "Blue", value: $blueComponent)
                .onChange(of: blueComponent) { _ in
                    setColor(updateColorFromRGB())
                }
        }
    }

    // Set the color based on the source of change
    private func setColor(_ newColor: Color) {
        withAnimation(.smooth(duration: 0.2)) {
            color = newColor
        }
    }

    // Update the color from RGB components
    private func updateColorFromRGB() -> Color {
        Color(
            red: redComponent / 255.0,
            green: greenComponent / 255.0,
            blue: blueComponent / 255.0
        )
    }

    // Update components when the color changes
    private func updateComponents(newValue: Color) {
        hexColor = newValue.toHex()
        let rgb = newValue.toRGB()
        redComponent = rgb.red
        greenComponent = rgb.green
        blueComponent = rgb.blue
    }
}
