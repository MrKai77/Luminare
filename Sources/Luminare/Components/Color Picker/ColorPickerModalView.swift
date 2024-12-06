//
//  ColorPickerModalView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

public struct RGBColorNames<R, G, B> where R: View, G: View, B: View {
    @ViewBuilder public var red: () -> R
    @ViewBuilder public var green: () -> G
    @ViewBuilder public var blue: () -> B
}

// MARK: - Color Picker (Modal)

// view for the color popup as a whole
struct ColorPickerModalView<R, G, B, Done>: View where R: View, G: View, B: View, Done: View {
    typealias ColorNames = RGBColorNames<R, G, B>

    // MARK: Environments

    @Environment(\.dismiss) private var dismiss
    @Environment(\.luminareAnimationFast) private var animationFast

    // MARK: Fields

    @Binding var selectedColor: HSBColor
    @Binding var hexColor: String

    var colorNames: ColorNames
    @ViewBuilder var done: () -> Done

    @State private var redComponent: Double = .zero
    @State private var greenComponent: Double = .zero
    @State private var blueComponent: Double = .zero

    @State private var isRedStepperPresented: Bool = false
    @State private var isGreenStepperPresented: Bool = false
    @State private var isBlueStepperPresented: Bool = false

    private let colorSampler = NSColorSampler()

    // MARK: Body

    // main view containing all components of the color picker
    var body: some View {
        Group {
            LuminareSection(hasPadding: false) {
                VStack(spacing: 2) {
                    ColorSaturationBrightnessView(selectedColor: $selectedColor)
                        .scaledToFill()
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 8,
                                bottomLeadingRadius: 2,
                                bottomTrailingRadius: 2,
                                topTrailingRadius: 8
                            )
                        )

                    ColorHueSliderView(selectedColor: $selectedColor, roundedBottom: true)
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
            .luminareHasDividers(false)

            RGBInputFields

            HStack {
                Button {
                    colorSampler.show { nsColor in
                        if let nsColor {
                            selectedColor = Color(nsColor: nsColor).hsb
                            updateComponents(selectedColor)
                        }
                    }
                } label: {
                    Image(systemName: "eyedropper.halffull")
                        .padding(-4)
                }
                .aspectRatio(1, contentMode: .fit)
                .fixedSize()
                .buttonStyle(LuminareCompactButtonStyle())

                Button {
                    dismiss()
                } label: {
                    done()
                }
                .buttonStyle(LuminareCompactButtonStyle())
            }
        }
        .onAppear {
            updateComponents(selectedColor)
        }
        .onChange(of: selectedColor) { color in
            updateComponents(color)
        }
        .onChange(of: internalColor) { color in
            selectedColor = color
        }
        .animation(animationFast, value: selectedColor)
    }

    // view for RGB input fields
    @ViewBuilder private var RGBInputFields: some View {
        HStack(spacing: 8) {
            RGBInputField(value: $redComponent) {
                colorNames.red()
            } color: { value in
                .init(
                    red: value / 255.0,
                    green: greenComponent / 255.0,
                    blue: blueComponent / 255.0
                )
            }

            RGBInputField(value: $greenComponent) {
                colorNames.green()
            } color: { value in
                .init(
                    red: redComponent / 255.0,
                    green: value / 255.0,
                    blue: blueComponent / 255.0
                )
            }

            RGBInputField(value: $blueComponent) {
                colorNames.blue()
            } color: { value in
                .init(
                    red: redComponent / 255.0,
                    green: greenComponent / 255.0,
                    blue: value / 255.0
                )
            }
        }
    }

    private var internalColor: HSBColor {
        let hsb = Color(red: redComponent / 255.0, green: greenComponent / 255.0, blue: blueComponent / 255.0).hsb

        return if hsb.saturation == 0 || hsb.brightness == 0 {
            // preserve hue
            .init(hue: selectedColor.hue, saturation: hsb.saturation, brightness: hsb.brightness)
        } else {
            hsb
        }
    }

    // MARK: Functions

    // update components when the color changes
    private func updateComponents(_ newValue: HSBColor) {
        // check if changed externally
        guard newValue != internalColor else { return }

        let rgb = newValue.rgb
        hexColor = rgb.toHex()

        let components = rgb.components
        redComponent = components.red * 255.0
        greenComponent = components.green * 255.0
        blueComponent = components.blue * 255.0
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "ColorPickerModalView",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var color: HSBColor = Color.accentColor.hsb
    @Previewable @State var hexColor = ""

    LuminareSection {
        ColorPickerModalView(
            selectedColor: $color,
            hexColor: $hexColor,
            colorNames: .init {
                Text("Red")
            } green: {
                Text("Green")
            } blue: {
                Text("Blue")
            }
        ) {
            Text("Done")
        }
    }
    .frame(width: 300)
}
