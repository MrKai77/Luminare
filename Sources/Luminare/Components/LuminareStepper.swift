//
//  LuminareStepper.swift
//
//
//  Created by KrLite on 2024/10/31.
//

import SwiftUI

@available(macOS 15.0, *)
public enum LuminareStepperAlignment {
    case none
    case center
    case leading // the left side of the growth direction, typically the top if horizontal and the left if vertical
    case trailing // opposite to `leading`

    // swiftlint:disable:next cyclomatic_complexity
    func hardPaddingEdges(of direction: LuminareStepperDirection) -> Edge.Set {
        switch self {
        case .none:
            direction.paddingEdges
        case .center:
            []
        case .leading:
            switch direction {
            case .horizontal:
                    .bottom
            case .horizontalAlternate:
                    .top
            case .vertical:
                    .trailing
            case .verticalAlternate:
                    .leading
            }
        case .trailing:
            switch direction {
            case .horizontal:
                    .top
            case .horizontalAlternate:
                    .bottom
            case .vertical:
                    .leading
            case .verticalAlternate:
                    .trailing
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func softPaddingEdges(of direction: LuminareStepperDirection) -> Edge.Set {
        switch self {
        case .none:
            []
        case .center:
            direction.paddingEdges
        case .leading:
            switch direction {
            case .horizontal:
                    .top
            case .horizontalAlternate:
                    .bottom
            case .vertical:
                    .leading
            case .verticalAlternate:
                    .trailing
            }
        case .trailing:
            switch direction {
            case .horizontal:
                    .bottom
            case .horizontalAlternate:
                    .top
            case .vertical:
                    .trailing
            case .verticalAlternate:
                    .leading
            }
        }
    }
}

@available(macOS 15.0, *)
public enum LuminareStepperDirection {
    case horizontal // the growth direction is typically right
    case horizontalAlternate // opposite to `horizontal`
    case vertical // the growth direction is typically up
    case verticalAlternate // opposite to `vertical`

    var isAlternate: Bool {
        switch self {
        case .horizontal, .vertical:
            false
        case .horizontalAlternate, .verticalAlternate:
            true
        }
    }

    var axis: Axis {
        switch self {
        case .horizontal, .horizontalAlternate:
                .horizontal
        case .vertical, .verticalAlternate:
                .vertical
        }
    }

    var unitSpan: (start: UnitPoint, end: UnitPoint) {
        switch self {
        case .horizontal:
            (start: .leading, end: .trailing)
        case .horizontalAlternate:
            (start: .trailing, end: .leading)
        case .vertical:
            (start: .bottom, end: .top)
        case .verticalAlternate:
            (start: .top, end: .bottom)
        }
    }

    var paddingSpan: (start: Edge.Set, end: Edge.Set) {
        switch self {
        case .horizontal:
            (start: .leading, end: .trailing)
        case .horizontalAlternate:
            (start: .trailing, end: .leading)
        case .vertical:
            (start: .bottom, end: .top)
        case .verticalAlternate:
            (start: .top, end: .bottom)
        }
    }

    var paddingEdges: Edge.Set {
        switch self {
        case .horizontal, .horizontalAlternate:
                .vertical
        case .vertical, .verticalAlternate:
                .horizontal
        }
    }

    @ViewBuilder func stack(spacing: CGFloat, @ViewBuilder content: @escaping () -> some View) -> some View {
        switch self {
        case .horizontal, .horizontalAlternate:
            HStack(alignment: .center, spacing: spacing, content: content)
        case .vertical, .verticalAlternate:
            VStack(alignment: .center, spacing: spacing, content: content)
        }
    }

    func frame(_ value: CGFloat?, fallback: CGFloat? = nil) -> (width: CGFloat?, height: CGFloat?) {
        switch self {
        case .horizontal, .horizontalAlternate:
            (width: value, height: fallback)
        case .vertical, .verticalAlternate:
            (width: fallback, height: value)
        }
    }

    func length(of size: CGSize) -> CGFloat {
        switch self {
        case .horizontal, .horizontalAlternate:
            size.width
        case .vertical, .verticalAlternate:
            size.height
        }
    }

    func offset(of point: CGPoint) -> CGFloat {
        switch self {
        case .horizontal, .horizontalAlternate:
            point.x
        case .vertical, .verticalAlternate:
            point.y
        }
    }

    func percentage(in total: CGFloat, at index: CGFloat) -> CGFloat {
        let percentage = index / total
        return switch self {
        case .horizontal, .verticalAlternate:
            percentage
        case .vertical, .horizontalAlternate:
            1 - percentage
        }
    }

    func offsetBy<Value: Numeric>(_ value: Value = .zero, nonAlternateOffset offset: Value) -> Value {
        switch self {
        case .horizontal, .verticalAlternate:
            value + offset
        case .vertical, .horizontalAlternate:
            value - offset
        }
    }
}

@available(macOS 15.0, *)
public enum LuminareStepperSource<V> where V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    case finite(range: ClosedRange<V>, stride: V = V(1))
    case finiteContinuous(range: ClosedRange<V>, stride: V = V(1))
    case infinite(stride: V = V(1))
    case infiniteContinuous(stride: V = V(1))

    var isFinite: Bool {
        switch self {
        case .finite, .finiteContinuous:
            true
        case .infinite, .infiniteContinuous:
            false
        }
    }

    var isContinuous: Bool {
        switch self {
        case .finiteContinuous, .infiniteContinuous:
            true
        case .finite, .infinite:
            false
        }
    }

    var count: Int? {
        switch self {
        case .finite(let range, let stride), .finiteContinuous(let range, let stride):
            Int(((range.upperBound - range.lowerBound) / stride).rounded(.down)) + 1
        default:
            nil
        }
    }

    var total: V? {
        switch self {
        case .finite(let range, _), .finiteContinuous(let range, _):
            range.upperBound - range.lowerBound
        case .infinite, .infiniteContinuous:
            nil
        }
    }

    var stride: V {
        switch self {
        case .finite(_, let stride), .finiteContinuous(_, let stride),
                .infinite(let stride), .infiniteContinuous(let stride):
            stride
        }
    }

    func round(_ value: V) -> (value: V, offset: V) {
        switch self {
        case .finite(let range, let stride), .finiteContinuous(let range, let stride):
            let diff = value - range.lowerBound
            let remainder = diff.truncatingRemainder(dividingBy: stride)
            return (value - remainder, remainder)
        case .infinite(let stride), .infiniteContinuous(let stride):
            let remainder = value.truncatingRemainder(dividingBy: stride)
            return (value - remainder, remainder)
        }
    }

    func continuousIndex(of value: V) -> V? {
        switch self {
        case .finite(let range, let stride), .finiteContinuous(let range, let stride):
            (value - range.lowerBound) / stride
        default:
            nil
        }
    }

    func isEdgeCase(_ value: V) -> Bool {
        switch self {
        case .finite(let range, let stride), .finiteContinuous(let range, let stride):
            let min = range.lowerBound + stride
            let max = range.upperBound - stride

            return value < min || value > max
        case .infinite, .infiniteContinuous:
            return false
        }
    }

    func reachedUpperBound(_ value: V, padding: V = .zero) -> Bool {
        switch self {
        case .finite(let range, _), .finiteContinuous(let range, _):
            value + padding >= range.upperBound
        case .infinite, .infiniteContinuous:
            false
        }
    }

    func reachedLowerBound(_ value: V, padding: V = .zero) -> Bool {
        switch self {
        case .finite(let range, _), .finiteContinuous(let range, _):
            value - padding <= range.lowerBound
        case .infinite, .infiniteContinuous:
            false
        }
    }

    func reachedStartingBound(_ value: V, padding: V = .zero, direction: LuminareStepperDirection) -> Bool {
        switch direction {
        case .horizontal, .vertical:
            reachedLowerBound(value, padding: padding)
        case .horizontalAlternate, .verticalAlternate:
            reachedUpperBound(value, padding: padding)
        }
    }

    func reachedEndingBound(_ value: V, padding: V = .zero, direction: LuminareStepperDirection) -> Bool {
        switch direction {
        case .horizontal, .vertical:
            reachedUpperBound(value, padding: padding)
        case .horizontalAlternate, .verticalAlternate:
            reachedLowerBound(value, padding: padding)
        }
    }

    func wrap(_ value: V) -> V {
        switch self {
        case .finite(let range, _), .finiteContinuous(let range, _):
            max(range.lowerBound, min(range.upperBound, value))
        case .infinite, .infiniteContinuous:
            value
        }
    }

    func offsetBy(
        _ value: V = .zero,
        direction: LuminareStepperDirection,
        nonAlternateOffset offset: V,
        wrap: Bool = true
    ) -> V {
        let result = switch direction {
        case .horizontal, .verticalAlternate:
            value + offset
        case .vertical, .horizontalAlternate:
            value - offset
        }

        return if wrap {
            self.wrap(result)
        } else {
            result
        }
    }
}

@available(macOS 15.0, *)
public struct LuminareStepperProminentIndicators<V>
where V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    @ViewBuilder let color: (V) -> Color?

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

@available(macOS 15.0, *)
public struct LuminareStepper<V>: View where V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    public typealias Alignment = LuminareStepperAlignment
    public typealias Direction = LuminareStepperDirection
    public typealias Source = LuminareStepperSource<V>
    public typealias ProminentIndicators = LuminareStepperProminentIndicators<V>

    // MARK: Environments

    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimationFast) private var animationFast

    // MARK: Fields

    @Binding private var value: V
    @State private var roundedValue: V
    @State private var internalValue: V // do not use computed vars, otherwise lagging occurs
    private let source: Source

    private let alignment: Alignment
    private let direction: Direction
    private let indicatorSpacing: CGFloat, maxSize: CGFloat, margin: CGFloat

    private let hasHierarchy: Bool, hasMask: Bool, hasBlur: Bool

    private let prominentIndicators: ProminentIndicators
    private let feedback: (V) -> SensoryFeedback?

    @State private var containerSize: CGSize = .zero
    @State private var diff: Int = .zero
    @State private var offset: CGFloat

    @State private var shouldScrollViewReset: Bool = true

    // MARK: Initializers

    public init(
        value: Binding<V>,
        source: Source,

        alignment: Alignment = .trailing,
        direction: Direction = .horizontal,
        indicatorSpacing: CGFloat = 25,
        maxSize: CGFloat = 70,
        margin: CGFloat = 8,

        hasHierarchy: Bool = true,
        hasMask: Bool = true,
        hasBlur: Bool = true,

        prominentIndicators: ProminentIndicators = .init(),
        feedback: @escaping (V) -> SensoryFeedback? = { _ in .alignment }
    ) {
        self._value = value
        self.source = source

        self.alignment = alignment
        self.direction = direction
        self.indicatorSpacing = indicatorSpacing
        self.maxSize = maxSize
        self.margin = margin

        self.hasHierarchy = hasHierarchy
        self.hasMask = hasMask
        self.hasBlur = hasBlur

        self.prominentIndicators = prominentIndicators
        self.feedback = feedback

        let rounded = source.round(value.wrappedValue)
        self.offset = CGFloat(rounded.offset)
        self.roundedValue = rounded.value
        self.internalValue = value.wrappedValue
    }

    public init(
        value: Binding<V>,
        source: Source,

        alignment: Alignment = .trailing,
        direction: Direction = .horizontal,
        indicatorSpacing: CGFloat = 25,
        maxSize: CGFloat = 70,
        margin: CGFloat = 8,

        hasHierarchy: Bool = true,
        hasMask: Bool = true,
        hasBlur: Bool = true,

        prominentValues: [V]? = nil,
        prominentColor: @escaping (V) -> Color? = { _ in nil },
        feedback: @escaping (V) -> SensoryFeedback? = { _ in .alignment }
    ) {
        self.init(
            value: value,
            source: source,

            alignment: alignment,
            direction: direction,
            indicatorSpacing: indicatorSpacing,
            maxSize: maxSize,
            margin: margin,

            hasHierarchy: hasHierarchy,
            hasMask: hasMask,
            hasBlur: hasBlur,

            prominentIndicators: .init(prominentValues, color: prominentColor),
            feedback: feedback
        )
    }

    // MARK: Body

    public var body: some View {
        direction.stack(spacing: indicatorSpacing) {
            ForEach(0..<indicatorCount, id: \.self) { index in
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
        let offsetFrame = direction.frame(-sigmoidOffset)
        let referencingValue = referencingValue(at: index)

        Group {
            let frame = direction.frame(2)
            let prominentTint = prominentIndicators.color(referencingValue)

            Color.clear
                .overlay {
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: frame.width, height: frame.height)
                        .tint(prominentTint ?? tint())
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
                        sigmoidOffset,
                        nonAlternateOffset: indicatorSpacing
                    )
                )
            let offsetEnd = direction.offsetBy(
                    nonAlternateOffset: direction.offsetBy(
                        -sigmoidOffset,
                         nonAlternateOffset: indicatorSpacing
                    )
                )

            let offsetCompensate = -indicatorSpacing / 2

            Color.white
                .padding(
                    direction.paddingSpan.start,
                    indexSpanStart * indicatorSpacing - offsetStart + offsetCompensate
                )
                .padding(
                    direction.paddingSpan.end,
                    indexSpanEnd * indicatorSpacing - offsetEnd + offsetCompensate
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

    @ViewBuilder private func scrollOverlay() -> some View {
        GeometryReader { proxy in
            Color.clear
                .overlay {
                    InfiniteScrollView(
                        direction: .init(axis: direction.axis),
                        size: proxy.size,
                        spacing: indicatorSpacing,
                        snapping: !source.isContinuous,
                        shouldReset: $shouldScrollViewReset,
                        wrapping: .init {
                            !source.isEdgeCase(internalValue)
                        } set: { _ in
                            // do nothing
                        },
                        initialOffset: .init {
                            if source.reachedEndingBound(internalValue, direction: direction) {
                                indicatorSpacing
                            } else if source.reachedStartingBound(internalValue, direction: direction) {
                                -indicatorSpacing
                            } else {
                                0
                            }
                        } set: { _ in
                            // do nothing
                        },
                        offset: $offset,
                        diff: $diff
                    )
                    .onChange(of: diff) { oldValue, newValue in
                        // do not use `+=`, otherwise causing multiple assignments
                        roundedValue = source.offsetBy(
                            roundedValue,
                            direction: direction,
                            nonAlternateOffset: V(newValue - oldValue) * source.stride
                        )
                    }
                    .onChange(of: offset) { _, newValue in
                        let offset = newValue / indicatorSpacing
                        let valueOffset = V(offset) * source.stride
                        internalValue = source.offsetBy(
                            roundedValue,
                            direction: direction,
                            nonAlternateOffset: valueOffset.truncatingRemainder(dividingBy: source.stride)
                        )
                    }
                    .onChange(of: internalValue) { _, _ in
                        value = internalValue
                    }
                    .onChange(of: value) { _, newValue in
                        // check if changed externally
                        guard newValue != internalValue else { return }
                        internalValue = newValue

                        let rounded = source.round(newValue)
                        roundedValue = rounded.value
                        offset = CGFloat(rounded.offset)
                    }
                }
        }
    }

    private var indicatorOffset: CGFloat {
        if source.reachedUpperBound(internalValue) {
            direction.offsetBy(offset, nonAlternateOffset: -indicatorSpacing)
        } else if source.reachedLowerBound(internalValue) {
            direction.offsetBy(offset, nonAlternateOffset: indicatorSpacing)
        } else {
            offset
        }
    }

    private var sigmoidOffset: CGFloat {
        let progress = indicatorOffset / indicatorSpacing
        let bent = bentSigmoid(progress)
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
        direction.offsetBy(CGFloat(centerIndicatorIndex - index), nonAlternateOffset: sigmoidOffset / indicatorSpacing)
    }

    private func referencingValue(at index: Int) -> V {
        let relativeIndex = index - centerIndicatorIndex
        return roundedValue + V(relativeIndex) * source.stride
    }

    private func magnifyFactor(at index: Int) -> CGFloat {
        let standardDeviation = 0.5
        let value = bellCurve(shift(at: index), standardDeviation: standardDeviation)
        let maxValue = bellCurve(0, standardDeviation: standardDeviation)
        return value / maxValue
    }

    private func blurFactor(at index: Int) -> CGFloat {
        let standardDeviation = CGFloat(indicatorCount - 2)
        let value = bellCurve(shift(at: index), standardDeviation: standardDeviation)
        let maxValue = bellCurve(0, standardDeviation: standardDeviation)
        return 1 - value / maxValue
    }

    /// Generates a bell curve value for a given x, mean, standard deviation, and amplitude.
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
        guard value >= -1 && value <= 1 else { return value }

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
    var alignment: LuminareStepperAlignment = .trailing
    var direction: LuminareStepperDirection = .horizontal
    var prominentValues: [V]
    @ViewBuilder var label: () -> Label

    var body: some View {
        LuminareSection {
            label()

            LuminareStepper(
                value: $value,
                source: source,
                alignment: alignment,
                direction: direction,
                prominentValues: prominentValues
            ) { _ in
                    .accentColor
            }
            .environment(\.luminareTint) { .primary }
//            .background(.quinary)

            HStack {
                Text(String(format: "%.1f", CGFloat(value)))

//                Button("42") {
//                    value = 42
//                }
            }
        }
        .padding()
    }
}

@available(macOS 15.0, *)
private struct StepperPopoverPreview: View {
    @State private var isPresented: Bool = false
    @State private var value: CGFloat = 42

    var body: some View {
        HStack {
            Button("Toggle Popover") {
                isPresented.toggle()
            }
            .popover(isPresented: $isPresented) {
                LuminareStepper(
                    value: $value,
                    source: .finite(range: 0...100, stride: 1),
                    direction: .horizontal,
                    indicatorSpacing: 10,
                    maxSize: 32
                )
                .environment(\.luminareTint) { .primary }
                .frame(width: 100, height: 32)
            }

//            Button("42") {
//                value = 42
//            }
        }

        Text(String(format: "%.1f", value))
    }
}

@available(macOS 15.0, *)
#Preview("LuminareStepper") {
    VStack {
        HStack {
            VStack {
                StepperPreview(
                    value: 42,
                    source: .finite(range: -100...50, stride: 2),
                    direction: .horizontal,
                    prominentValues: [0, 42, 50]
                ) {
                    VStack {
                        Text("Horizontal")
                            .bold()

                        Text("Snapping Enabled")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                StepperPreview(
                    value: 42,
                    source: .infiniteContinuous(stride: 2),
                    direction: .horizontalAlternate,
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
            }
            .frame(width: 500)

            HStack {
                StepperPreview(
                    value: 42,
                    source: .finite(range: -100...50, stride: 2),
                    alignment: .center,
                    direction: .vertical,
                    prominentValues: [0, 38, 40, 42]
                ) {
                    VStack {
                        Text("Vertical Center Aligned")
                            .bold()

                        Text("Snapping Enabled")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                StepperPreview(
                    value: 42,
                    source: .finiteContinuous(range: -100...50, stride: 2),
                    direction: .verticalAlternate,
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
            }
            .frame(width: 300)
        }
        .multilineTextAlignment(.center)

//        StepperPopoverPreview()
    }
    .padding()
}
