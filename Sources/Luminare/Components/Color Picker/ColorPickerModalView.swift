//
//  ColorPickerModalView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// MARK: - Color Picker (Modal)

struct ColorPickerModalView: View {
    // MARK: Environments

    @Environment(\.dismiss) private var dismiss
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareColorPickerHasCancel) private var hasCancel
    @Environment(\.luminareColorPickerHasDone) private var hasDone

    // MARK: Fields

    @Binding var selectedColor: Color
    @Binding var hexColor: String

    var hasColorPicker: Bool = true

    @State private var initialColor: Color = .black

    @State private var redComponent: Double = .zero
    @State private var greenComponent: Double = .zero
    @State private var blueComponent: Double = .zero

    @State private var isRedStepperPresented: Bool = false
    @State private var isGreenStepperPresented: Bool = false
    @State private var isBlueStepperPresented: Bool = false

    @State private var hueFallback: Double = .zero

    private let colorSampler = NSColorSampler()

    // MARK: Body

    var body: some View {
        Group {
            LuminareSection(hasPadding: false) {
                VStack(spacing: 2) {
                    let color = Binding {
                        internalHSBColor
                    } set: { newValue in
                        hueFallback = newValue.hue
                        updateComponents(newValue.rgb)
                        selectedColor = newValue.rgb
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
        .onChange(of: internalHSBColor) { newValue in
            selectedColor = newValue.rgb
        }
        .animation(animationFast, value: internalHSBColor)
    }

    private var internalHSBColor: HSBColor {
        let hsb = Color(red: redComponent / 255.0, green: greenComponent / 255.0, blue: blueComponent / 255.0).hsb

        if hsb.saturation == 0 || hsb.brightness == 0 {
            // Preserve hue
            return .init(
                hue: hueFallback,
                saturation: hsb.saturation,
                brightness: hsb.brightness
            )
        } else {
            hueFallback = hsb.hue
            return hsb
        }
    }

    private var hasControls: Bool {
        hasCancel || hasDone
    }

    private var hasCancelAndDone: Bool {
        hasCancel && hasDone
    }

    @ViewBuilder private func rgbInputFields() -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            RGBInputField(value: $redComponent) {
                Text("Red")
            } color: { value in
                .init(
                    red: value / 255.0,
                    green: greenComponent / 255.0,
                    blue: blueComponent / 255.0
                )
            }

            RGBInputField(value: $greenComponent) {
                Text("Blue")
            } color: { value in
                .init(
                    red: redComponent / 255.0,
                    green: value / 255.0,
                    blue: blueComponent / 255.0
                )
            }

            RGBInputField(value: $blueComponent) {
                Text("Green")
            } color: { value in
                .init(
                    red: redComponent / 255.0,
                    green: greenComponent / 255.0,
                    blue: value / 255.0
                )
            }

            // Display color picker inline with RGB input fields
            if (!hasControls && hasColorPicker) || hasCancelAndDone {
                colorPicker()
            }
        }
        .luminareAspectRatio(contentMode: .fill)
    }

    @ViewBuilder private func controls() -> some View {
        if hasControls {
            HStack(spacing: 4) {
                // Display color picker inline with controls
                if !hasCancelAndDone, hasColorPicker {
                    colorPicker()
                }

                Group {
                    if hasCancel {
                        Button("Cancel") {
                            // Revert selected color
                            selectedColor = initialColor
                            dismiss()
                        }
                        .foregroundStyle(.red)
                    }

                    if hasDone {
                        Button("Done") {
                            selectedColor = internalHSBColor.rgb
                            initialColor = selectedColor
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.luminareCompact)
                .luminareAspectRatio(contentMode: .fill)
            }
        }
    }

    @ViewBuilder private func colorPicker() -> some View {
        Button {
            colorSampler.show { nsColor in
                if let nsColor {
                    updateComponents(Color(nsColor: nsColor))
                }
            }
        } label: {
            Image(systemName: "eyedropper.halffull")
        }
        .luminareAspectRatio(1 / 1, contentMode: .fit)
        .buttonStyle(.luminareCompact)
    }

    // MARK: Functions

    private func updateComponents(_ color: Color) {
        // Check if changed externally
        guard color != .init(hsb: internalHSBColor) else { return }

        hexColor = color.toHex()

        let components = color.components
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
    @Previewable @FocusState var isFocused: Bool

    @Previewable @State var color = Color.accentColor
    @Previewable @State var hexColor = ""

//    color.frame(width: 50, height: 50)

    VStack {
        ColorPickerModalView(
            selectedColor: $color,
            hexColor: $hexColor
        )
        .luminareColorPickerControls(hasDone: true)
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .onAppear {
            isFocused = true
        }
    }
    .frame(width: 260)
    .fixedSize()
//    .foregroundStyle(color)
}
