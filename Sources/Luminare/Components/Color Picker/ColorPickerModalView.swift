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
    
    @State private var isRedStepperPresented: Bool = false
    @State private var isGreenStepperPresented: Bool = false
    @State private var isBlueStepperPresented: Bool = false
    
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
                            updateComponents(color)
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
            updateComponents(color)
        }
        .onChange(of: color) { _ in
            updateComponents(color)
        }
    }

    // view for RGB input fields
    private var RGBInputFields: some View {
        HStack(spacing: 8) {
            RGBInputField(value: $redComponent) {
                colorNames.red
            } color: { value in
                let progress = value / 255.0
                return .init(
                    red: progress,
                    green: 1 - progress,
                    blue: 1 - progress
                )
            }
            .onChange(of: redComponent) { _ in
                setColor(internalColor)
            }
            
            RGBInputField(value: $greenComponent) {
                colorNames.green
            } color: { value in
                let progress = value / 255.0
                return .init(
                    red: 1 - progress,
                    green: progress,
                    blue: 1 - progress
                )
            }
            .onChange(of: greenComponent) { _ in
                setColor(internalColor)
            }
            
            RGBInputField(value: $blueComponent) {
                colorNames.blue
            } color: { value in
                let progress = value / 255.0
                return .init(
                    red: 1 - progress,
                    green: 1 - progress,
                    blue: progress
                )
            }
            .onChange(of: blueComponent) { _ in
                setColor(internalColor)
            }
        }
    }
    
    private var internalColor: Color {
        Color(
            red: redComponent / 255.0,
            green: greenComponent / 255.0,
            blue: blueComponent / 255.0
        )
    }

    // set the color based on the source of change
    private func setColor(_ newColor: Color) {
        withAnimation(animationFast) {
            color = newColor
        }
    }

    // update components when the color changes
    private func updateComponents(_ newValue: Color) {
        hexColor = newValue.toHex()
        
        // check if changed externally
        guard newValue != internalColor else { return }
        let rgb = newValue.toRGB()
        
        redComponent = rgb.red
        greenComponent = rgb.green
        blueComponent = rgb.blue
    }
}

private struct ColorPickerModalPreview: View {
    @State private var color: Color = .accentColor
    @State private var hexColor: String = ""
    
    var body: some View {
        ColorPickerModalView(
            color: $color,
            hexColor: $hexColor,
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

#Preview {
    LuminareSection {
        ColorPickerModalPreview()
    }
    .padding()
    .frame(width: 300)
}
