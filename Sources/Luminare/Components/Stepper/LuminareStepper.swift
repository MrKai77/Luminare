//
//  LuminareStepper.swift
//  Luminare
//
//  Created by KrLite on 2024/10/31.
//

import SwiftUI

/// A custom delegate to customize any indicators of a ``LuminareStepper``.
@available(macOS 15.0, *)
public struct LuminareStepperProminentIndicators<V>
    where V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    @ViewBuilder let color: (V) -> Color?

    /// Initializes a ``LuminareStepperProminentIndicators``.
    ///
    /// - Parameters:
    ///   - values: a convenient array to roughly filter out unwanted values.
    ///   If `nil`, all values will be available in the following closure.
    ///   Otherwise, only values contained in this array will be available.
    ///   - color: a closure to provide customized prominent colors for indicators that represent certain values.
    ///   However, you might have to vaguely decide of which range the indicators will fall if the step is not an
    ///   integer.
    public init(
        _ values: [V]? = nil,
        color: @escaping (V) -> Color? = { _ in nil }
    ) {
        if let values {
            self.color = { value in
                if values.contains(value) {
                    color(value)
                } else {
                    nil
                }
            }
        } else {
            self.color = color
        }
    }
}

// MARK: - Stepper

/// A stylized, abstract stepper that provides vague yet elegant control to numeric values.
@available(macOS 15.0, *)
public struct LuminareStepper<V>: View where V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    public typealias Source = LuminareStepperSource<V>
    public typealias ProminentIndicators = LuminareStepperProminentIndicators<V>

    // MARK: Environments

    @Environment(\.luminareTintColor) private var tintColor
    @Environment(\.luminareStepperAlignment) private var alignment
    @Environment(\.luminareStepperDirection) private var direction

    // MARK: Fields

    @Binding private var value: V
    @State private var roundedValue: V
    @State private var internalValue: V // do not use computed vars, otherwise lagging occurs
    private let source: Source

    private let indicatorSpacing: CGFloat, maxSize: CGFloat, margin: CGFloat

    private let hasHierarchy: Bool, hasMask: Bool, hasBlur: Bool

    private let prominentIndicators: ProminentIndicators
    private let feedback: (V) -> SensoryFeedback?

    private let onRoundedValueChange: ((V, V) -> ())?

    @State private var containerSize: CGSize = .zero
    @State private var page: Int = .zero
    @State private var offset: CGFloat

    @State private var shouldScrollViewReset: Bool = true
    @State private var scrollViewID: UUID = .init() // used for trigger reinitializations

    // MARK: Initializers

    /// Initializes a ``LuminareStepper``.
    ///
    /// - Parameters:
    ///   - value: the value to be edited.
    ///   - source: the ``LuminareStepperSource`` that defines how the value will be clamped and snapped.
    ///   - indicatorSpacing: the spacing between indicators.
    ///   This directly influnces the sensitivity since the span between two indicators will always be a step.
    ///   - maxSize: the max length of the span that perpendiculars to the stepper direction.
    ///   - margin: the margin to inset the indicators from the edges based on the alignment.
    ///   - hasHierarchy: whether the indicators placed further to the center have lighter opacities.
    ///   - hasMask: whether to apply the gradient mask to the indicators to form a faded effect.
    ///   - hasBlur: whether to blur the edged indicators.
    ///   - prominentIndicators: the ``ProminentIndicators`` that defines how the indicators will be colored.
    ///   - feedback: provides feedback when received changes of certain strided values.
    ///   - onRoundedValueChange: callback when rounded value changes.
    ///   Useful for listening to correctly rounded values instead of rounding towards zero.
    public init(
        value: Binding<V>,
        source: Source,

        indicatorSpacing: CGFloat = 25,
        maxSize: CGFloat = 70,
        margin: CGFloat = 8,

        hasHierarchy: Bool = true,
        hasMask: Bool = true,
        hasBlur: Bool = true,

        prominentIndicators: ProminentIndicators = .init(),
        feedback: @escaping (V) -> SensoryFeedback? = { _ in .alignment },

        onRoundedValueChange: ((V, V) -> ())? = nil
    ) {
        self._value = value
        self.source = source

        self.indicatorSpacing = indicatorSpacing
        self.maxSize = maxSize
        self.margin = margin

        self.hasHierarchy = hasHierarchy
        self.hasMask = hasMask
        self.hasBlur = hasBlur

        self.prominentIndicators = prominentIndicators
        self.feedback = feedback

        self.onRoundedValueChange = onRoundedValueChange

        let rounded = source.round(value.wrappedValue)
        self.offset = .zero // apply later
        self.roundedValue = rounded.value
        self.internalValue = value.wrappedValue

        self.offset = direction.offsetBy(nonAlternateOffset: CGFloat(rounded.offset / source.step) * indicatorSpacing)
    }

    /// Initializes a ``LuminareStepper``.
    ///
    /// - Parameters:
    ///   - value: the value to be edited.
    ///   - source: the ``LuminareStepperSource`` that defines how the value will be clamped and snapped.
    ///   - indicatorSpacing: the spacing between indicators.
    ///   This directly influnces the sensitivity since the span between two indicators will always be a step.
    ///   - maxSize: the max length of the span that perpendiculars to the stepper direction.
    ///   - margin: the margin to inset the indicators from the edges based on the alignment.
    ///   - hasHierarchy: whether the indicators placed further to the center have lighter opacities.
    ///   - hasMask: whether to apply the gradient mask to the indicators to form a faded effect.
    ///   - hasBlur: whether to blur the edged indicators.
    ///   - prominentValues: the values marked as prominent.
    ///   - prominentColor: defines the colors of the indicators whose represented values are filtered by
    ///   `prominentValues`.
    ///   - feedback: provides feedback when received changes of certain strided values.
    ///   - onRoundedValueChange: callback when rounded value changes.
    ///   Useful for listening to correctly rounded values instead of rounding towards zero.
    public init(
        value: Binding<V>,
        source: Source,

        indicatorSpacing: CGFloat = 25,
        maxSize: CGFloat = 70,
        margin: CGFloat = 8,

        hasHierarchy: Bool = true,
        hasMask: Bool = true,
        hasBlur: Bool = true,

        prominentValues: [V]? = nil,
        prominentColor: @escaping (V) -> Color? = { _ in nil },
        feedback: @escaping (V) -> SensoryFeedback? = { _ in .alignment },

        onRoundedValueChange: ((V, V) -> ())? = nil
    ) {
        self.init(
            value: value,
            source: source,

            indicatorSpacing: indicatorSpacing,
            maxSize: maxSize,
            margin: margin,

            hasHierarchy: hasHierarchy,
            hasMask: hasMask,
            hasBlur: hasBlur,

            prominentIndicators: .init(prominentValues, color: prominentColor),
            feedback: feedback,

            onRoundedValueChange: onRoundedValueChange
        )
    }

    // MARK: Body

    public var body: some View {
        direction.stack(spacing: indicatorSpacing) {
            ForEach(0 ..< indicatorCount, id: \.self) { index in
                let relativeIndex = index - centerIndicatorIndex
                let index = direction.offsetBy(
                    centerIndicatorIndex,
                    nonAlternateOffset: relativeIndex
                )
                indicator(at: index)
            }
        }
        .frame(minWidth: minFrame.width, minHeight: minFrame.height)
        .frame(maxWidth: maxFrame.width, maxHeight: maxFrame.height)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { _, newValue in
            containerSize = newValue
        }
        .mask(bleedingMask)
        .mask(visualMask)
        .overlay(content: scrollOverlay)
        .sensoryFeedback(trigger: roundedValue) { oldValue, newValue in
            guard oldValue != newValue else { return nil }
            return feedback(newValue)
        }
    }

    @ViewBuilder private func indicator(at index: Int) -> some View {
        let frame = direction.frame(0)
        let offsetFrame = direction.frame(-bentOffset)
        let referencingValue = referencingValue(at: index)

        Group {
            let frame = direction.frame(2)
            let prominentTint = prominentIndicators.color(referencingValue)

            Color.clear
                .overlay {
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: frame.width, height: frame.height)
                        .tint(prominentTint ?? tintColor)
                        .foregroundStyle(
                            .tint.opacity(hasHierarchy ? pow(0.5 + 0.5 * magnifyFactor(at: index), 2.0) : 1)
                        )
                }
                .padding(alignment.hardPaddingEdges(of: direction), margin)
                .padding(alignment.softPaddingEdges(of: direction), margin * (1 - magnifyFactor(at: index)))
                .blur(radius: hasBlur ? indicatorSpacing * blurFactor(at: index) : 0)
        }
        .frame(width: frame.width, height: frame.height)
        .offset(x: offsetFrame.width ?? 0, y: offsetFrame.height ?? 0)
    }

    @ViewBuilder private func bleedingMask() -> some View {
        if let count = source.count, let index = source.continuousIndex(of: roundedValue), source.isFinite {
            let indexSpanStart = max(0, CGFloat(centerIndicatorIndex) - CGFloat(index))
            let indexSpanEnd = max(0, CGFloat(centerIndicatorIndex) - (CGFloat(count) - 1 - CGFloat(index)))

            let offsetStart = direction.offsetBy(
                nonAlternateOffset: direction.offsetBy(
                    bentOffset,
                    nonAlternateOffset: indicatorSpacing
                )
            )
            let offsetEnd = direction.offsetBy(
                nonAlternateOffset: direction.offsetBy(
                    -bentOffset,
                    nonAlternateOffset: indicatorSpacing
                )
            )

            let offsetCompensation = -indicatorSpacing / 2

            Color.white
                .padding(
                    direction.paddingSpan.start,
                    indexSpanStart * indicatorSpacing - offsetStart + offsetCompensation + 1
                )
                .padding(
                    direction.paddingSpan.end,
                    indexSpanEnd * indicatorSpacing - offsetEnd + offsetCompensation + 1
                )
        } else {
            Color.white
        }
    }

    @ViewBuilder private func visualMask() -> some View {
        if hasMask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: -0.2),
                    .init(color: .white, location: 0.4),
                    .init(color: .white, location: 0.6),
                    .init(color: .clear, location: 1.2)
                ],
                startPoint: direction.unitSpan.start,
                endPoint: direction.unitSpan.end
            )
        } else {
            Color.white
        }
    }

    private func scrollOverlay() -> some View {
        GeometryReader { proxy in
            Color.clear
                .overlay {
                    infiniteScrollView(proxy: proxy)
                        .onChange(of: page) { oldValue, newValue in
                            // Do not use `+=`, otherwise causing multiple assignments
                            roundedValue = source.offsetBy(
                                roundedValue,
                                direction: direction,
                                nonAlternateOffset: V(newValue - oldValue) * source.step
                            )
                        }
                        .onChange(of: offset) { _, newValue in
                            let offset = newValue / indicatorSpacing
                            let correctedOffset = if source.reachedStartingBound(roundedValue, direction: direction) {
                                direction.offsetBy(offset, nonAlternateOffset: 1)
                            } else if source.reachedEndingBound(roundedValue, direction: direction) {
                                direction.offsetBy(offset, nonAlternateOffset: -1)
                            } else {
                                offset
                            }

                            let valueOffset = V(correctedOffset) * source.step
                            internalValue = source.offsetBy(
                                roundedValue,
                                direction: direction,
                                nonAlternateOffset: valueOffset.truncatingRemainder(dividingBy: source.step)
                            )
                        }
                        .onChange(of: internalValue) { _, _ in
                            value = internalValue
                        }
                        .onChange(of: value) { _, newValue in
                            // Check if changed externally
                            guard newValue != internalValue else { return }
                            internalValue = newValue

                            let rounded = source.round(newValue)
                            roundedValue = rounded.value
                            offset = CGFloat(rounded.offset)
                        }
                        .onChange(of: roundedValue, initial: true) { oldValue, newValue in
                            onRoundedValueChange?(oldValue, newValue)
                        }
                }
        }
    }

    private func infiniteScrollView(proxy: GeometryProxy) -> some View {
        InfiniteScrollView(
            direction: .init(axis: direction.axis),

            size: proxy.size,
            spacing: indicatorSpacing,
            snapping: snapping,
            wrapping: wrapping,
            initialOffset: initialOffset,

            shouldReset: $shouldScrollViewReset,
            offset: $offset,
            page: $page
        )
        .id(scrollViewID)
        .onChange(of: proxy.size) {
            // Force reinitialize the scroll view to conform to the new size
            scrollViewID = .init()
        }
    }

    private var snapping: Bool {
        !source.isContinuous
    }

    private var wrapping: Bool {
        !source.isEdgeCase(internalValue)
    }

    private var initialOffset: CGFloat {
        if source.reachedEndingBound(internalValue, direction: direction) {
            indicatorSpacing
        } else if source.reachedStartingBound(internalValue, direction: direction) {
            -indicatorSpacing
        } else {
            offset
        }
    }

    private var indicatorOffset: CGFloat {
        if source.reachedUpperBound(roundedValue) {
            direction.offsetBy(offset, nonAlternateOffset: -indicatorSpacing)
        } else if source.reachedLowerBound(roundedValue) {
            direction.offsetBy(offset, nonAlternateOffset: indicatorSpacing)
        } else {
            offset
        }
    }

    private var bentOffset: CGFloat {
        let progress = indicatorOffset / indicatorSpacing
        let bent = bentSigmoid(progress, curvature: source.isContinuous ? 0 : 7.5)
        return bent * indicatorSpacing
    }

    private var minFrame: (width: CGFloat?, height: CGFloat?) {
        direction.frame(3 * indicatorSpacing)
    }

    private var maxFrame: (width: CGFloat?, height: CGFloat?) {
        direction.frame(.infinity, fallback: maxSize)
    }

    private var indicatorCount: Int {
        let possibleCount = Int(floor(containerLength / indicatorSpacing))
        let oddCount = if possibleCount.isMultiple(of: 2) {
            possibleCount - 1
        } else {
            possibleCount
        }
        return max(3, oddCount) + 4 // 4 is abundant for edged indicators to appear continuously
    }

    private var centerIndicatorIndex: Int {
        indicatorCount.quotientAndRemainder(dividingBy: 2).quotient
    }

    private var containerLength: CGFloat {
        direction.length(of: containerSize)
    }

    // MARK: Functions

    private func shift(at index: Int) -> CGFloat {
        direction.offsetBy(CGFloat(centerIndicatorIndex - index), nonAlternateOffset: bentOffset / indicatorSpacing)
    }

    private func referencingValue(at index: Int) -> V {
        let relativeIndex = index - centerIndicatorIndex
        return roundedValue + V(relativeIndex) * source.step
    }

    private func magnifyFactor(at index: Int) -> CGFloat {
        let standardDeviation = 0.5
        let value = bellCurve(shift(at: index), standardDeviation: standardDeviation)
        return value
    }

    private func blurFactor(at index: Int) -> CGFloat {
        let standardDeviation = CGFloat(indicatorCount - 2)
        let value = bellCurve(shift(at: index), standardDeviation: standardDeviation)
        return 1 - value
    }

    /// Generates a bell curve value for a given x, mean, standard deviation, and amplitude.
    /// It's worth noting that the integral of this bell curve is not 1, instead, the max value of this bell curve is always 1.
    /// - Parameters:
    ///   - x: The x-value at which to evaluate the bell curve.
    ///   - mean: The mean (center) of the bell curve.
    ///   - standardDeviation: The standard deviation (width) of the bell curve. Higher values result in a wider curve.
    ///   - amplitude: The peak (height) of the bell curve.
    /// - Returns: The y-value of the bell curve at the given x.
    private func bellCurve(
        _ value: CGFloat,
        mean: CGFloat = .zero,
        standardDeviation: CGFloat,
        amplitude: CGFloat = 1
    ) -> CGFloat {
        let exponent = -pow(value - mean, 2) / (2 * pow(standardDeviation, 2))
        return amplitude * exp(exponent)
    }

    /// Sigmoid-like function that bends the input curve around 0.5.
    /// - Parameters:
    ///   - x: The input value, expected to be in the range [0, 1].
    ///   - curvature: A parameter to control the curvature. Higher values create a sharper bend.
    /// - Returns: The transformed output in the range [0, 1].
    private func bentSigmoid(
        _ value: Double,
        curvature: Double = 7.5
    ) -> Double {
        guard curvature != 0 else { return value }
        guard value >= -1, value <= 1 else { return value }

        return if value >= 0 {
            1 / (1 + exp(-curvature * (value - 0.5)))
        } else {
            -bentSigmoid(-value)
        }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
private struct StepperPreview<Label, V>: View
    where Label: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    @State var value: V
    var source: LuminareStepperSource<V>
    var prominentValues: [V]
    @ViewBuilder var label: () -> Label

    var body: some View {
        LuminareSection {
            label()

            LuminareStepper(
                value: $value,
                source: source,
                prominentValues: prominentValues
            ) { _ in
                .accentColor
            } onRoundedValueChange: { _, newValue in
                print(newValue)
            }
            .luminareTint(overridingWith: .primary)
//            .background(.quinary)

            HStack {
                Text(String(format: "%.1f", CGFloat(value)))

//                Button("42") {
//                    value = 42
//                }
            }
        }
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareStepper",
    traits: .sizeThatFitsLayout
) {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            VStack(spacing: 20) {
                StepperPreview(
                    value: 42,
                    source: .finite(in: -100...50, step: 2),
                    prominentValues: [0, 42, 50]
                ) {
                    VStack {
                        Text("Horizontal")
                            .bold()

                        Text("Finite Snapping")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                StepperPreview(
                    value: 45,
                    source: .infiniteContinuous(step: 2),
                    prominentValues: [0, 42]
                ) {
                    VStack {
                        Text("Horizontal Alternate")
                            .bold()

                        Text("Infinite Continuous")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .luminareStepperDirection(.horizontalAlternate)

                StepperPreview(
                    value: 42,
                    source: .infinite(step: 2),
                    prominentValues: [0, 26, 30, 34, 38, 42, 46, 50, 54, 58]
                ) {
                    VStack {
                        Text("Horizontal Center Aligned")
                            .bold()

                        Text("Infinite Snapping")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .luminareStepperAlignment(.center)
                .luminareStepperDirection(.horizontal)
            }
            .frame(width: 450)

            HStack(spacing: 20) {
                StepperPreview(
                    value: 42,
                    source: .finite(in: -100...50, step: 2),
                    prominentValues: [0, 38, 40, 42]
                ) {
                    VStack {
                        Text("Vertical Center Aligned")
                            .bold()

                        Text("Finite Snapping")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .luminareStepperAlignment(.center)
                .luminareStepperDirection(.vertical)

                StepperPreview(
                    value: 42,
                    source: .finiteContinuous(in: -100...50, step: 2),
                    prominentValues: [0, 38, 40, 42]
                ) {
                    VStack {
                        Text("Vertical Alternate")
                            .bold()

                        Text("Finite Continuous")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .luminareStepperDirection(.verticalAlternate)
            }
            .frame(width: 250)
        }
        .multilineTextAlignment(.center)

//        StepperPopoverPreview()
    }
}
