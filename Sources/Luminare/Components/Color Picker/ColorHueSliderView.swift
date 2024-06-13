//
//  ColorHueSliderView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

struct ColorHueSliderView: View {
    @Binding var selectedColor: Color
    @State private var selectionPosition: CGFloat = 0
    @State private var selectionOffset: CGFloat = 0

    // Gradient for the color spectrum slider
    private let colorSpectrumGradient = Gradient(
        colors: stride(from: 0.0, through: 1.0, by: 0.01)
            .map {
                Color(hue: $0, saturation: 1, brightness: 1)
            }
    )

    init(selectedColor: Binding<Color>) {
        self._selectedColor = selectedColor
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: colorSpectrumGradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                RoundedRectangle(cornerRadius: handleCornerRadius(at: selectionPosition, geo.size.width))
                    .frame(width: handleWidth(at: selectionPosition, geo.size.width), height: 12)
                    .offset(x: selectionOffset, y: 0)
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .onChange(of: selectionPosition) { _ in
                        withAnimation(.smooth(duration: 0.2)) {
                            selectionOffset = calculateOffset(handleWidth: handleWidth(at: selectionPosition, geo.size.width), geo.size.width)
                        }
                    }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChange(value, geo.size.width)
                    }
            )
            .onAppear {
                selectionPosition = selectedColor.toHSB().hue * geo.size.width
                selectionOffset = calculateOffset(handleWidth: handleWidth(at: selectionPosition, geo.size.width), geo.size.width)
            }
        }
        .frame(height: 16)
    }

    private func handleDragChange(_ value: DragGesture.Value, _ viewSize: CGFloat) {
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

    private func calculateOffset(handleWidth: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let halfWidth = handleWidth / 2
        let adjustedPosition = min(max(selectionPosition, halfWidth), viewSize - halfWidth)
        return adjustedPosition - halfWidth
    }

    private func handleWidth(at position: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = 1 - max(0, min(edgeDistance / 10, 1))
        return max(5, min(10, 5 + (5 * edgeFactor)))
    }

    private func handleCornerRadius(at position: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = max(0, min(edgeDistance / 5, 1))
        return max(2, 15 * edgeFactor)
    }
}
