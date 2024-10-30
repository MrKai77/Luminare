//
//  ColorPickerModalView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

public typealias RGBColorNames<R, G, B> = (
    red: R,
    green: G,
    blue: B
)


// view for the color popup as a whole
struct ColorPickerModalView<R, G, B, Done>: View
where R: View, G: View, B: View, Done: View {
    typealias ColorNames = RGBColorNames<R, G, B>
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.luminareAnimationFast) private var animationFast
    
    @Binding var color: Color
    @Binding var hexColor: String

    let colorNames: ColorNames
    @ViewBuilder let done: () -> Done
    
    @State private var redComponent: Double = 0
    @State private var greenComponent: Double = 0
    @State private var blueComponent: Double = 0
    
    private let colorSampler = NSColorSampler()

    // main view containing all components of the color picker
    var body: some View {
        Group {
            LuminareSection(hasPadding: false, hasDividers: false) {
                VStack(spacing: 2) {
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
            
            HStack {
                Button {
                    colorSampler.show { nsColor in
                        if let nsColor {
                            setColor(.init(nsColor: nsColor))
                            updateComponents(newValue: color)
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
            updateComponents(newValue: color)
        }
        .onChange(of: color) { _ in
            updateComponents(newValue: color)
        }
    }

    // view for RGB input fields
    private var RGBInputFields: some View {
        HStack(spacing: 8) {
            RGBInputField(value: $redComponent) {
                colorNames.red
            }
            .onChange(of: redComponent) { _ in
                setColor(updateColorFromRGB())
            }
            
            RGBInputField(value: $greenComponent) {
                colorNames.green
            }
            .onChange(of: greenComponent) { _ in
                setColor(updateColorFromRGB())
            }
            
            RGBInputField(value: $blueComponent) {
                colorNames.blue
            }
            .onChange(of: blueComponent) { _ in
                setColor(updateColorFromRGB())
            }
        }
    }

    // set the color based on the source of change
    private func setColor(_ newColor: Color) {
        withAnimation(animationFast) {
            color = newColor
        }
    }

    // update the color from RGB components
    private func updateColorFromRGB() -> Color {
        Color(
            red: redComponent / 255.0,
            green: greenComponent / 255.0,
            blue: blueComponent / 255.0
        )
    }

    // update components when the color changes
    private func updateComponents(newValue: Color) {
        hexColor = newValue.toHex()
        let rgb = newValue.toRGB()
        
        redComponent = rgb.red
        greenComponent = rgb.green
        blueComponent = rgb.blue
    }
}

#Preview {
    LuminareSection {
        VStack {
            ColorPickerModalView(
                color: .constant(.accentColor),
                hexColor: .constant("ffffff"),
                colorNames: (
                    red: Text("Red"),
                    green: Text("Green"),
                    blue: Text("Blue")
                )
            ) {
                Text("Done")
            }
        }
    }
    .padding()
    .frame(width: 300, height: 400)
}
