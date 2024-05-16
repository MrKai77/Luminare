//
//  LuminareColorPicker.swift
//
//
//  Created by Kai Azim on 2024-05-13.
//

import SwiftUI

public struct LuminareColorPicker: View {
    @Binding var currentColor: Color

    @State private var color: Color
    @State private var text: String

    @State private var showColorPicker = false

    public init(color: Binding<Color>) {
        self._currentColor = color
        self._color = State(initialValue: color.wrappedValue)
        self._text = State(initialValue: color.wrappedValue.toHex())
    }

    public var body: some View {
        HStack {
            LuminareTextField(
                $text,
                placeHolder: "Hex Color",
                onSubmit: {
                    if let newColor = Color(hex: text) {
                        text = newColor.toHex()
                        withAnimation(.smooth(duration: 0.3)) {
                            color = newColor
                        }
                    } else {
                        text = color.toHex()    // revert to last color
                    }
                }
            )
            .modifier(LuminareBordered())

            Button {
                showColorPicker.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(self.color)
                    .frame(width: 26, height: 26)
                    .padding(4)
                    .modifier(LuminareBordered())
            }
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $showColorPicker) {
                ColorPickerPopover(color: $color, hexColor: $text, showColorPicker: $showColorPicker)
            }
        }
        .onChange(of: color) { _ in
            currentColor = color
        }
    }
}

// MARK: - Color Popup View

// View for the color popup as a whole
struct ColorPickerPopover: View {
    @Binding var color: Color
    @Binding var hexColor: String
    @Binding var showColorPicker: Bool
    @State private var selectionPosition: CGFloat = 0
    @State private var redComponent: Double = 0
    @State private var greenComponent: Double = 0
    @State private var blueComponent: Double = 0
    @State private var lastChangeSource: ChangeSource = .none

    // Gradient for the color spectrum slider
    private let colorSpectrumGradient = ColorUtils.generateSpectrumGradient()

    // Main view containing all components of the color picker
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 2) {
                // Lightness adjustment view
                ColorLightnessView(selectedColor: $color, lastChangeSource: $lastChangeSource)
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
                colorSpectrumSlider
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
        .onAppear(perform: updateRGBComponents)
        .onChange(of: color, perform: updateComponents)
    }

    // View for the color spectrum slider
    private var colorSpectrumSlider: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: colorSpectrumGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxHeight: .infinity)
                    .gesture(
                        DragGesture(minimumDistance: 0).onChanged({ value in
                            let clampedX = max(0, min(value.location.x, geometry.size.width))
                            selectionPosition = clampedX
                            let percentage = selectionPosition / geometry.size.width
                            setColor(colorFromSpectrum(percentage: Double(percentage)), changeSource: .colorSpectrum)
                        })
                    )

                RoundedRectangle(
                    cornerRadius: handleCornerRadius(at: selectionPosition, within: geometry.size.width),
                    style: .continuous
                )
                .frame(
                    width: handleWidth(at: selectionPosition, within: geometry.size.width),
                    height: 12
                )
                .offset(
                    x: handleOffset(
                        at: selectionPosition,
                        handleWidth: handleWidth(at: selectionPosition, within: geometry.size.width),
                        within: geometry.size.width
                    ),
                    y: 0
                )
                .foregroundColor(.white)
                .shadow(radius: 3)
            }
            .onAppear {
                let huePercentage = color.toHSB().hue
                selectionPosition = huePercentage * geometry.size.width
            }
        }
        .frame(height: 16)
    }

    // Calculate the width of the handle based on its position
    private func handleWidth(
        at position: CGFloat,
        within totalWidth: CGFloat
    ) -> CGFloat {
        let edgeDistance = min(position, totalWidth - position)
        let edgeFactor = 1 - max(0, min(edgeDistance / 10, 1))
        return max(5, min(10, 5 + (5 * edgeFactor)))
    }

    // Calculate the corner radius of the handle based on its position
    private func handleCornerRadius(
        at position: CGFloat,
        within totalWidth: CGFloat
    ) -> CGFloat {
        let edgeDistance = min(position, totalWidth - position)
        let edgeFactor = max(0, min(edgeDistance / 5, 1))
        return max(2, 15 * edgeFactor)
    }

    // Calculate the offset of the handle to keep it within the slider bounds
    private func handleOffset(
        at position: CGFloat,
        handleWidth: CGFloat,
        within totalWidth: CGFloat
    ) -> CGFloat {
        let halfWidth = handleWidth / 2
        let adjustedPosition = min(max(position, halfWidth), totalWidth - halfWidth)
        return adjustedPosition - halfWidth
    }

    // View for RGB input fields
    private var RGBInputFields: some View {
        HStack(spacing: 8) {
            RGBInputField(label: "Red", value: $redComponent)
                .onChange(of: redComponent) { _ in
                    setColor(updateColorFromRGB(), changeSource: .rgbInput)
                }

            RGBInputField(label: "Green", value: $greenComponent)
                .onChange(of: greenComponent) { _ in 
                    setColor(updateColorFromRGB(), changeSource: .rgbInput)
                }

            RGBInputField(label: "Blue", value: $blueComponent)
                .onChange(of: blueComponent) { _ in 
                    setColor(updateColorFromRGB(), changeSource: .rgbInput)
                }
        }
        .padding(.top)
    }

    // Set the color based on the source of change
    private func setColor(_ newColor: Color, changeSource: ChangeSource) {
        withAnimation(.smooth(duration: 0.2)) {
            color = newColor
        }

        lastChangeSource = changeSource

        if changeSource == .colorSpectrum {
            updateRGBComponents()
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

    // Create a color from the spectrum based on a percentage
    private func colorFromSpectrum(percentage: Double) -> Color {
        Color(
            hue: 0.01 + (percentage * 0.98),
            saturation: color.toHSB().saturation,
            brightness: color.toHSB().brightness
        )
    }

    // Update RGB components from the current color
    private func updateRGBComponents() {
        let rgb = color.toRGB()
        redComponent = rgb.red
        greenComponent = rgb.green
        blueComponent = rgb.blue
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

struct ColorUtils {
    static func generateSpectrumGradient() -> Gradient {
        let hueValues = stride(from: 0.0, through: 1.0, by: 0.01).map {
            Color(hue: $0, saturation: 1, brightness: 1)
        }
        let gradient = Gradient(colors: hueValues)
        return gradient
    }
}

// Enum to track the source of color changes in the UI
enum ChangeSource {
    case colorSpectrum, rgbInput, none
}
// MARK: - UI Components

// Custom input field for RGB values
/// this also neeeds to be adjusted to
/// look like the given image
struct RGBInputField: View {
    var label: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)

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
                        .strokeBorder(.quinary.opacity(0.5), lineWidth: 1)
                }
        }
    }
}

// MARK: - Color Lightness View

// View for adjusting the lightness of a selected color
struct ColorLightnessView: View {
    @Binding var selectedColor: Color
    @Binding var lastChangeSource: ChangeSource

    @State private var circlePosition: CGPoint = .zero
    @State private var originalHue: CGFloat = 0
    @State private var originalSaturation: CGFloat = 0
    @State private var isDragging: Bool = false

    private let viewSize: CGFloat = 276
    private let circleSize: CGFloat = 12

    var body: some View {
        ZStack {
            Color(
                hue: originalHue,
                saturation: originalSaturation,
                brightness: 1
            )

            LinearGradient(
                gradient: Gradient(colors: [.white.opacity(0), .white]),
                startPoint: .trailing,
                endPoint: .leading
            )

            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0), .black]),
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .frame(width: circleSize, height: circleSize)
                .foregroundColor(selectedColor)
                .background {
                    Circle()
                        .stroke(.white, lineWidth: 6)
                }
                .shadow(radius: 3)
                .offset(
                    x: circlePosition.x - viewSize / 2,
                    y: circlePosition.y - viewSize / 2
                )
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    updateCirclePosition(value.location)
                }
                .onEnded { value in
                    isDragging = false
                    updateCirclePosition(value.location)
                }
        )
        .onTapGesture {
            let tapLocation = CGPoint(x: viewSize / 2, y: viewSize / 2)
            updateCirclePosition(tapLocation)
        }
        .contentShape(Rectangle())
        .frame(width: viewSize, height: viewSize)

        .onAppear {
            initializeCirclePosition()
        }
        .onChange(of: selectedColor) { newValue in
            if !isDragging && lastChangeSource != .none {
                let hsb = newValue.toHSB()
                originalHue = hsb.hue
                originalSaturation = hsb.saturation
                initializeCirclePosition()
            }
        }
    }

    // Update the position of the circle based on user interaction
    private func updateCirclePosition(_ location: CGPoint) {
        let adjustedX = max(0, min(location.x, viewSize))
        let adjustedY = max(0, min(location.y, viewSize))

        withAnimation(.smooth(duration: 0.2)) {
            circlePosition = CGPoint(x: adjustedX, y: adjustedY)
        }

        // Only adjust brightness if dragging, to avoid overwriting with white or black
        if isDragging {
            let brightness = 1 - (adjustedY / viewSize)
            let saturation = (adjustedX / viewSize)
            selectedColor = Color(
                hue: Double(originalHue),
                saturation: Double(saturation),
                brightness: Double(brightness)
            )
        }
    }

    // Initialize the position of the circle based on the current color
    private func initializeCirclePosition() {
        let hsb = selectedColor.toHSB()
        circlePosition = CGPoint(
            x: CGFloat(hsb.saturation) * viewSize,
            y: (1 - CGFloat(hsb.brightness)) * viewSize
        )
    }
}
