//
//  ColorPickerPopover.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// View for the color popup as a whole
struct ColorPickerPopover: View {
    @Binding var color: Color
    @Binding var hexColor: String
    @State private var redComponent: Double = 0
    @State private var greenComponent: Double = 0
    @State private var blueComponent: Double = 0

    // Main view containing all components of the color picker
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 2) {
                // Lightness adjustment view
                ColorSaturationBrightnessView(selectedColor: $color)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 2,
                            bottomTrailingRadius: 2,
                            topTrailingRadius: 12
                        )
                    )

                // Color spectrum slider
                /// this vied needs to be finalised
                /// currently it does not really look like the img
                ColorHueSliderView(selectedColor: $color)
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

            .background(.quinary.opacity(0.5))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 16
                )
            )
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 16
                )
                .strokeBorder(.quinary.opacity(0.5), lineWidth: 1)
            }

            // RGB input fields
            /// this needs to be changed to more support the img
            /// this would be edited above, as this is defined
            /// outside of the scope
            RGBInputFields
        }
        .padding(8)
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
        .padding(.top)
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
