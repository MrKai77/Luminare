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
                saturation: 1,
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

//            Circle()
//                .frame(width: circleSize, height: circleSize)
//                .foregroundColor(selectedColor)
//                .background {
//                    Circle()
//                        .stroke(.white, lineWidth: 6)
//                }
//                .shadow(radius: 3)
            ColorPickerCircle(selectedColor: $selectedColor, isDragging: $isDragging, circleSize: circleSize)
                .offset(
                    x: circlePosition.x - viewSize / 2,
                    y: circlePosition.y - viewSize / 2
                )
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    updateColor(value.location)
                }
                .onEnded { value in
                    isDragging = false
                    updateColor(value.location)
                }
        )
        .frame(width: viewSize, height: viewSize)

        .onAppear {
            let hsb = selectedColor.toHSB()
            originalHue = hsb.hue
            originalSaturation = hsb.saturation
            updateCirclePosition()
        }
        .onChange(of: selectedColor) { _ in
            if !isDragging {
                let hsb = selectedColor.toHSB()
                originalHue = hsb.hue
                originalSaturation = hsb.saturation
                updateCirclePosition()
            }
        }
    }

    // Update the position of the circle based on user interaction
    private func updateColor(_ location: CGPoint) {
        let adjustedX = max(0, min(location.x, viewSize))
        let adjustedY = max(0, min(location.y, viewSize))

        // Only adjust brightness if dragging, to avoid overwriting with white or black
        if isDragging {
            let brightness = 1 - (adjustedY / viewSize)
            let saturation = (adjustedX / viewSize)
            selectedColor = Color(
                hue: Double(originalHue),
                saturation: Double(saturation),
                brightness: Double(max(0.0001, brightness))
            )
        }

        withAnimation(.smooth(duration: 0.2)) {
            updateCirclePosition()
        }
    }

    // Initialize the position of the circle based on the current color
    private func updateCirclePosition() {
        let hsb = selectedColor.toHSB()

        if hsb.saturation <= 0.0001 {
            circlePosition = CGPoint(
                x: .zero,
                y: (1 - CGFloat(hsb.brightness)) * viewSize
            )
        } else {
            circlePosition = CGPoint(
                x: CGFloat(hsb.saturation) * viewSize,
                y: (1 - CGFloat(hsb.brightness)) * viewSize
            )
        }
    }
}


struct ColorPickerCircle: View {
    @Binding var selectedColor: Color
    @Binding var isDragging: Bool

    @State private var isHovering: Bool = false
    private let circleSize: CGFloat

    init(selectedColor: Binding<Color>, isDragging: Binding<Bool>, circleSize: CGFloat) {
        self._selectedColor = selectedColor
        self._isDragging = isDragging
        self.circleSize = circleSize
    }

    var body: some View {
        Circle()
            .frame(width: circleSize, height: circleSize)
            .foregroundColor(selectedColor)
            .background {
                Circle()
                    .stroke(.white, lineWidth: 6)
            }
            .shadow(radius: 3)

            .scaleEffect((isHovering && !isDragging) ? 1.25 : 1.0)
            .onHover { hovering in
                isHovering = hovering
            }
            .animation(.smooth(duration: 0.2), value: [isHovering, isDragging])
    }
}
