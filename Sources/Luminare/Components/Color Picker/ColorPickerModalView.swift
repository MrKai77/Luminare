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
struct ColorPickerModalView<R, G, B>: View where R: View, G: View, B: View {
    typealias ColorNames = RGBColorNames<R, G, B>

    // MARK: Environments

    @Environment(\.dismiss) private var dismiss
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareColorPickerCancelView) private var cancelView
    @Environment(\.luminareColorPickerDoneView) private var doneView

    // MARK: Fields

    @Binding var selectedColor: HSBColor
    @Binding var hexColor: String

    var colorNames: ColorNames
    var hasColorPicker: Bool = true

    @State private var initialColor: HSBColor = .init(rgb: .black)

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
                    let color = Binding {
                        internalColor
                    } set: { newValue in
                        updateComponents(newValue)
                        selectedColor = newValue
                    }

                    ColorSaturationBrightnessView(selectedColor: color)
                        .scaledToFill()
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 8,
                                bottomLeadingRadius: 2,
                                bottomTrailingRadius: 2,
                                topTrailingRadius: 8
                            )
                        )

                    ColorHueSliderView(selectedColor: color, roundedBottom: true)
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

            rgbInputFields()

            controls()
        }
        .onAppear {
            updateComponents(selectedColor)
            initialColor = selectedColor
        }
        .onChange(of: selectedColor) { color in
            updateComponents(color)
        }
        .onChange(of: internalColor) { newValue in
            selectedColor = newValue
        }
        .animation(animationFast, value: internalColor)
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

    @ViewBuilder private func rgbInputFields() -> some View {
        HStack(alignment: .bottom, spacing: 4) {
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

            if hasColorPicker {
                Button {
                    colorSampler.show { nsColor in
                        if let nsColor {
                            updateComponents(Color(nsColor: nsColor).hsb)
                        }
                    }
                } label: {
                    Image(systemName: "eyedropper.halffull")
                }
                .luminareCompactButtonAspectRatio(1 / 1, contentMode: .fit)
                .buttonStyle(.luminareCompact)
            }
        }
        .luminareCompactButtonAspectRatio(contentMode: .fill)
    }

    @ViewBuilder private func controls() -> some View {
        let cancelView = cancelView(), hasCancel = cancelView != nil
        let doneView = doneView(), hasDone = doneView != nil

        if hasCancel || hasDone {
            HStack(spacing: 4) {
                Group {
                    if let cancelView {
                        Button {
                            // revert selected color
                            selectedColor = initialColor
                            dismiss()
                        } label: {
                            cancelView
                        }
                        .foregroundStyle(.red)
                    }

                    if let doneView {
                        Button {
                            selectedColor = internalColor
                            initialColor = selectedColor
                            dismiss()
                        } label: {
                            doneView
                        }
                    }
                }
                .buttonStyle(.luminareCompact)
                .luminareCompactButtonAspectRatio(contentMode: .fill)
            }
        }
    }

    // MARK: Functions

    private func updateComponents(_ color: HSBColor) {
        // check if changed externally
        guard color != internalColor else { return }

        let rgb = color.rgb
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

    Color(hsb: color)
        .frame(width: 50, height: 50)

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
        )
        .luminareColorPickerCancelView {
            Text("Cancel")
        }
        .luminareColorPickerDoneView {
            Text("Done")
        }
    }
    .frame(width: 300)
    .foregroundStyle(color.rgb)
}
