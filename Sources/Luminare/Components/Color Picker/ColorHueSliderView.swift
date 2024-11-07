//
//  ColorHueSliderView.swift
//
//
//  Created by Kai Azim on 2024-05-15.
//

import SwiftUI

// MARK: - Color Hue Slider

struct ColorHueSliderView: View {
    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation

    // MARK: Fields

    @Binding private var selectedColor: Color
    @State private var selectionPosition: CGFloat = 0
    @State private var selectionOffset: CGFloat = 0
    @State private var selectionCornerRadius: CGFloat = 0
    @State private var selectionWidth: CGFloat = 0

    // gradient for the color spectrum slider
    private let colorSpectrumGradient = Gradient(
        colors: stride(from: 0.0, through: 1.0, by: 0.01)
            .map {
                Color(hue: $0, saturation: 1, brightness: 1)
            }
    )

    // MARK: Initializers

    init(selectedColor: Binding<Color>) {
        self._selectedColor = selectedColor
    }

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: colorSpectrumGradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                UnevenRoundedRectangle(
                    topLeadingRadius: 2,
                    bottomLeadingRadius: selectionOffset < (geo.size.width / 2) ? selectionCornerRadius : 2,
                    bottomTrailingRadius: selectionOffset > (geo.size.width / 2) ? selectionCornerRadius : 2,
                    topTrailingRadius: 2
                )
                .frame(width: selectionWidth, height: 12.5)
                .padding(.bottom, 0.5)
                .offset(x: selectionOffset, y: 0)
                .foregroundColor(.white)
                .shadow(radius: 3)
                .onChange(of: selectionPosition) { _ in
                    withAnimation(animation) {
                        selectionOffset = calculateOffset(
                            handleWidth: handleWidth(at: selectionPosition, geo.size.width),
                            geo.size.width)
                        selectionWidth = handleWidth(at: selectionPosition, geo.size.width)
                        selectionCornerRadius = handleCornerRadius(at: selectionPosition, geo.size.width)
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
                selectionOffset = calculateOffset(
                    handleWidth: handleWidth(at: selectionPosition, geo.size.width),
                    geo.size.width)
                selectionWidth = handleWidth(at: selectionPosition, geo.size.width)
                selectionCornerRadius = handleCornerRadius(at: selectionPosition, geo.size.width)
            }
        }
        .frame(height: 16)
    }

    // MARK: Functions

    private func handleDragChange(_ value: DragGesture.Value, _ viewSize: CGFloat) {
        let lastPercentage = selectionPosition / viewSize

        let clampedX = max(5.5, min(value.location.x, viewSize - 5.5))
        selectionPosition = clampedX
        let percentage = selectionPosition / viewSize
        let currentHSB = selectedColor.toHSB()

        if percentage != lastPercentage, percentage == 5.5 / viewSize || percentage == (viewSize - 5.5) / viewSize {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        }

        withAnimation(animation) {
            selectedColor = Color(
                hue: percentage,
                saturation: max(0.0001, currentHSB.saturation),
                brightness: currentHSB.brightness
            )
        }
    }

    private func calculateOffset(handleWidth: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let halfWidth = handleWidth / 2
        let adjustedPosition = min(max(selectionPosition, halfWidth), viewSize - halfWidth)
        return adjustedPosition - halfWidth
    }

    private func handleWidth(at position: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = 1 - max(0, min(edgeDistance / 10, 1))
        return max(5, min(15, 5 + (6 * edgeFactor)))
    }

    private func handleCornerRadius(at position: CGFloat, _ viewSize: CGFloat) -> CGFloat {
        let edgeDistance = min(position, viewSize - position)
        let edgeFactor = max(0, min(edgeDistance / 5, 1))
        return 15 * edgeFactor
    }
}

// MARK: - Preview

#Preview("ColorHueSliderView") {
    LuminareSection {
        ColorHueSliderView(selectedColor: .constant(.accentColor))
    }
    .padding()
}
