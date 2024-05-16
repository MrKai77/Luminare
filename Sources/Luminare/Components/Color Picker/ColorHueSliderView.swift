//
//  ColorSpectrumSliderView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

struct ColorHueSliderView: View {
    @Binding var selectedColor: Color
    @State private var selectionPosition: CGFloat
    @State private var selectionOffset: CGFloat = 0

    // Gradient for the color spectrum slider
    private let colorSpectrumGradient = Gradient(
        colors: stride(from: 0.0, through: 1.0, by: 0.01)
            .map {
                Color(hue: $0, saturation: 1, brightness: 1)
            }
    )
    private let viewSize: CGFloat = 276

    init(selectedColor: Binding<Color>) {
        self._selectedColor = selectedColor

        let huePercentage = selectedColor.wrappedValue.toHSB().hue
        self._selectionPosition = State(initialValue: huePercentage * viewSize)
        self._selectionOffset = State(initialValue: calculateOffset(
            handleWidth: handleWidth(at: selectionPosition, within: viewSize),
            within: viewSize
        ))
    }

    var body: some View {
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
                        let clampedX = max(0, min(value.location.x, viewSize))
                        selectionPosition = clampedX
                        let percentage = selectionPosition / viewSize
                        setColor(colorFromSpectrum(percentage: Double(percentage)))
                    })
                )

            RoundedRectangle(
                cornerRadius: handleCornerRadius(at: selectionPosition, within: viewSize),
                style: .continuous
            )
            .frame(
                width: handleWidth(at: selectionPosition, within: viewSize),
                height: 12
            )
            .offset(
                x: selectionOffset,
                y: 0
            )
            .foregroundColor(.white)
            .shadow(radius: 3)
            .onChange(of: selectionPosition) { _ in
                withAnimation(.smooth(duration: 0.2)) {
                    selectionOffset = calculateOffset(
                        handleWidth: handleWidth(at: selectionPosition, within: viewSize),
                        within: viewSize
                    )
                }
            }
        }
        .frame(height: 16)
    }

    // Set the color based on the source of change
    private func setColor(_ newColor: Color) {
        withAnimation(.smooth(duration: 0.2)) {
            selectedColor = newColor
        }
    }

    // Create a color from the spectrum based on a percentage
    private func colorFromSpectrum(percentage: Double) -> Color {
        let currentColorHSB = selectedColor.toHSB()
        return Color(
            hue: 0.01 + (percentage * 0.99),
            saturation: max(currentColorHSB.saturation, 0.01),
            brightness: max(currentColorHSB.brightness, 0.01)
        )
    }

    // Calculate the offset of the handle to keep it within the slider bounds
    private func calculateOffset(
        handleWidth: CGFloat,
        within totalWidth: CGFloat
    ) -> CGFloat {
        let halfWidth = handleWidth / 2
        let adjustedPosition = min(max(selectionPosition, halfWidth), totalWidth - halfWidth)
        return adjustedPosition - halfWidth
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
}
