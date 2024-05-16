//
//  ColorLightnessView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// View for adjusting the lightness of a selected color
struct ColorSaturationBrightnessView: View {
    @Binding var selectedColor: Color

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
        .frame(width: viewSize, height: viewSize)

        .onAppear {
            let hsb = selectedColor.toHSB()
            originalHue = hsb.hue
            originalSaturation = hsb.saturation
            initializeCirclePosition()
        }
        .onChange(of: selectedColor) { _ in
            if !isDragging {
                let hsb = selectedColor.toHSB()
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
