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
        self._selectionOffset = State(initialValue: 0) // Initialized later in onAppear
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
                    DragGesture(minimumDistance: 0)
                        .onChanged(handleDragChange)
                )

            RoundedRectangle(cornerRadius: handleCornerRadius(at: selectionPosition))
                .frame(width: handleWidth(at: selectionPosition), height: 12)
                .offset(x: selectionOffset, y: 0)
                .foregroundColor(.white)
                .shadow(radius: 3)
                .onChange(of: selectionPosition) { _ in
                    withAnimation(.smooth(duration: 0.2)) {
                        selectionOffset = calculateOffset(handleWidth: handleWidth(at: selectionPosition))
                    }
                }
        }
        .frame(height: 16)
        .onAppear {
            selectionOffset = calculateOffset(handleWidth: handleWidth(at: selectionPosition))
        }
    }

    private func handleDragChange(_ value: DragGesture.Value) {
        let clampedX = max(0, min(value.location.x, viewSize))
        selectionPosition = clampedX
        let percentage = selectionPosition / viewSize
        setColor(colorFromSpectrum(percentage: Double(percentage)))
    }

    private func setColor(_ newColor: Color) {
        withAnimation(.smooth(duration: 0.2)) {
            selectedColor = newColor
        }
    }

    private func colorFromSpectrum(percentage: Double) -> Color {
        let hsb = selectedColor.toHSB()
        return Color(hue: 0.01 + (percentage * 0.99), saturation: max(0.0001, hsb.saturation), brightness: hsb.brightness)
    }

    private func calculateOffset(handleWidth: CGFloat) -> CGFloat {
        let halfWidth = handleWidth / 2
        let adjustedPosition = min(max(selectionPosition, halfWidth), viewSize - halfWidth)
        return adjustedPosition - halfWidth
    }

    private func handleWidth(at position: CGFloat) -> CGFloat {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = 1 - max(0, min(edgeDistance / 10, 1))
        return max(5, min(10, 5 + (5 * edgeFactor)))
    }

    private func handleCornerRadius(at position: CGFloat) -> CGFloat {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = max(0, min(edgeDistance / 5, 1))
        return max(2, 15 * edgeFactor)
    }
}
