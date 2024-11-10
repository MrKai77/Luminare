//
//  LuminareStepper.swift
//
//
//  Created by KrLite on 2024/10/31.
//

import SwiftUI

/// The indicator alignment of a ``LuminareStepper``.
@available(macOS 15.0, *)
public enum LuminareStepperAlignment {
    /// The indicators are of the equal lengths and expand to both edges.
    case none
    /// The indicators are of the equal lengths and have equal paddings from both edges.
    case center
    /// The center indicator is larger than others and points to the direction normals to the
    /// ``LuminareStepperDirection``.
    ///
    /// In left-to-right layouts, the indicators point to top if ``LuminareStepperDirection`` is
    ///  ``LuminareStepperDirection/horizontal`` and to left if ``LuminareStepperDirection`` is
    ///  ``LuminareStepperDirection/vertical``.
    case leading // the left side of the growth direction, typically the top if horizontal and the left if vertical
    /// The center indicator is larger than others and points to the direction negatively normals to the 
    /// ``LuminareStepperDirection``.
    ///
    /// In left-to-right layouts, the indicators point to bottom if ``LuminareStepperDirection`` is 
    /// ``LuminareStepperDirection/horizontal`` and to right if ``LuminareStepperDirection`` is
    /// ``LuminareStepperDirection/vertical``.
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

/// The direction of a ``LuminareStepper``.
@available(macOS 15.0, *)
public enum LuminareStepperDirection {
    /// In left-to-right layouts, the larger values are right-sided.
    case horizontal // the growth direction is typically right
    /// In left-to-right layouts, the larger values are left-sided.
    case horizontalAlternate // opposite to `horizontal`
    /// In left-to-right layouts, the larger values are upward.
    case vertical // the growth direction is typically up
    /// In left-to-right layouts, the larger values are downward.
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

/// Specifies how a ``LuminareStepper`` ranges and snaps its value.
@available(macOS 15.0, *)
public enum LuminareStepperSource<V> where V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    /// The value is finely ranged and strideable.
    ///
    /// The value will be strictly clamped inside a closed range and snapped to the nearest value according to the
    /// step.
    ///
    /// - Parameters:
    ///   - in: the closed range of the available values.
    ///   - step: the step between two snapped values.
    case finite(in: ClosedRange<V>, step: V = 1) // swiftlint:disable:this identifier_name
    /// The value is finely ranged but continuous.
    ///
    /// The value will be strictly clamped inside a closed range, but won't be snapped.
    ///
    /// In this case, the step only defines how many values are between two indicators.
    ///
    /// - Parameters:
    ///   - in: the closed range of the available values.
    ///   - step: the step between two indicators.
    case finiteContinuous(in: ClosedRange<V>, step: V = 1) // swiftlint:disable:this identifier_name
    /// The value is strideable but infinite.
    ///
    /// The value will be snapped to the nearest value according to the step, but won't be clamped.
    ///
    /// - Parameters:
    ///   - step: the step between two snapped values.
    case infinite(step: V = 1)
    /// The value is infinite and continuous.
    ///
    /// The value will be neither clamped nor snapped. All legal values of the type will be acceptable.
    ///
    /// In this case, the step only defines how many values are between two indicators.
    ///
    /// - Parameters:
    ///   - step: the step between two indicators.
    case infiniteContinuous(step: V = 1)

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
        case .finite(let range, let step), .finiteContinuous(let range, let step):
            Int(((range.upperBound - range.lowerBound) / step).rounded(.down)) + 1
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

    var step: V {
        switch self {
        case .finite(_, let step), .finiteContinuous(_, let step),
                .infinite(let step), .infiniteContinuous(let step):
            step
        }
    }

    func round(_ value: V) -> (value: V, offset: V) {
        switch self {
        case .finite(let range, let step), .finiteContinuous(let range, let step):
            let diff = value - range.lowerBound
            let remainder = diff.truncatingRemainder(dividingBy: step)
            return (value - remainder, remainder)
        case .infinite(let step), .infiniteContinuous(let step):
            let remainder = value.truncatingRemainder(dividingBy: step)
            return (value - remainder, remainder)
        }
    }

    func continuousIndex(of value: V) -> V? {
        switch self {
        case .finite(let range, let step), .finiteContinuous(let range, let step):
            (value - range.lowerBound) / step
        default:
            nil
        }
    }

    func isEdgeCase(_ value: V) -> Bool {
        switch self {
        case .finite(let range, let step), .finiteContinuous(let range, let step):
            let min = range.lowerBound + step
            let max = range.upperBound - step

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

    func wrap(_ value: V, padding: V = .zero) -> V {
        switch self {
        case .finite(let range, _), .finiteContinuous(let range, _):
            max(range.lowerBound + padding, min(range.upperBound - padding, value))
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

    /// Initializes a ``LuminareStepper``.
    ///
    /// - Parameters:
    ///   - value: the value to be edited.
    ///   - source: the ``LuminareStepperSource`` that defines how the value will be clamped and snapped.
    ///   - alignment: the ``LuminareStepperAlignment`` that defines the alignment of the indicators.
    ///   - direction: the ``LuminareStepperDirection`` that defines the direction of the stepper.
    ///   - indicatorSpacing: the spacing between indicators.
    ///   This directly influnces the sensitivity since the span between two indicators will always be a step.
    ///   - maxSize: the max length of the span that perpendiculars to the stepper direction.
    ///   - margin: the margin to inset the indicators from the edges based on the alignment.
    ///   - hasHierarchy: whether the indicators placed further to the center have lighter opacities.
    ///   - hasMask: whether to apply the gradient mask to the indicators to form a faded effect.
    ///   - hasBlur: whether to blur the edged indicators.
    ///   - prominentIndicators: the ``ProminentIndicators`` that defines how the indicators will be colored.
    ///   - feedback: provides feedback when received changes of certain strided values.
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
        self.offset = direction.offsetBy(nonAlternateOffset: CGFloat(rounded.offset / source.step) * indicatorSpacing)
        self.roundedValue = rounded.value
        self.internalValue = value.wrappedValue
    }

    /// Initializes a ``LuminareStepper``.
    ///
    /// - Parameters:
    ///   - value: the value to be edited.
    ///   - source: the ``LuminareStepperSource`` that defines how the value will be clamped and snapped.
    ///   - alignment: the ``LuminareStepperAlignment`` that defines the alignment of the indicators.
    ///   - direction: the ``LuminareStepperDirection`` that defines the direction of the stepper.
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
        let offsetFrame = direction.frame(-bentOffset)
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
                                offset
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
        guard curvature != 0 else { return value }
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
            .overrideTint { .primary }
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
                    source: .finite(in: 0...100, step: 1),
                    direction: .horizontal,
                    indicatorSpacing: 10,
                    maxSize: 32
                )
                .overrideTint { .primary }
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
                    direction: .horizontal,
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

                StepperPreview(
                    value: 42,
                    source: .infinite(step: 2),
                    alignment: .center,
                    direction: .horizontal,
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
            }
            .frame(width: 450)

            HStack(spacing: 20) {
                StepperPreview(
                    value: 42,
                    source: .finite(in: -100...50, step: 2),
                    alignment: .center,
                    direction: .vertical,
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

                StepperPreview(
                    value: 42,
                    source: .finiteContinuous(in: -100...50, step: 2),
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
            .frame(width: 250)
        }
        .multilineTextAlignment(.center)

//        StepperPopoverPreview()
    }
}
