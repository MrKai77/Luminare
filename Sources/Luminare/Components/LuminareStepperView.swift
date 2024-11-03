//
//  LuminareStepperView.swift
//
//
//  Created by KrLite on 2024/10/31.
//

import SwiftUI

@available(macOS 15.0, *)
public enum LuminareStepperAlignment {
    case none
    case centered
    case leading // the left side of the growth direction, typically the top if horizontal and the left if vertical
    case trailing // opposite to `leading`
    
    func hardPaddingEdges(of direction: LuminareStepperDirection) -> Edge.Set {
        switch self {
        case .none:
            direction.paddingEdges
        case .centered:
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
    
    func softPaddingEdges(of direction: LuminareStepperDirection) -> Edge.Set {
        switch self {
        case .none:
            []
        case .centered:
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
    
    func percentage(in total: CGFloat, at: CGFloat) -> CGFloat {
        let percentage = at / total
        return switch self {
        case .horizontal, .verticalAlternate:
            percentage
        case .vertical, .horizontalAlternate:
            1 - percentage
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
    
    func reachedUpperBound(_ value: V) -> Bool {
        switch self {
        case .finite(let range, _), .finiteContinuous(let range, _):
            value >= range.upperBound
        case .infinite, .infiniteContinuous:
            false
        }
    }
    
    func reachedLowerBound(_ value: V) -> Bool {
        switch self {
        case .finite(let range, _), .finiteContinuous(let range, _):
            value <= range.lowerBound
        case .infinite, .infiniteContinuous:
            false
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
    
    func offsetBy(_ value: V, direction: LuminareStepperDirection, nonAlternateOffset offset: V, wrap: Bool = true) -> V {
        let result = if direction.isAlternate {
            value - offset
        } else {
            value + offset
        }
        
        return if wrap {
            self.wrap(result)
        } else {
            result
        }
    }
    
    func offsetBy(_ value: CGFloat, direction: LuminareStepperDirection, nonAlternateOffset offset: CGFloat) -> CGFloat {
        if direction.isAlternate {
            value - offset
        } else {
            value + offset
        }
    }
}

@available(macOS 15.0, *)
public struct LuminareStepperProminentIndicators<Modifier, V> where Modifier: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    let values: [V]
    @ViewBuilder let modifier: (V, AnyView) -> Modifier
    
    public init(
        values: [V],
        @ViewBuilder modifier: @escaping (V, AnyView) -> Modifier
    ) {
        self.values = values
        self.modifier = modifier
    }
    
    public init() where Modifier == AnyView {
        self.init(values: []) { _, view in view }
    }
}

@available(macOS 15.0, *)
public struct LuminareStepperView<Modifier, V>: View where Modifier: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    public typealias Alignment = LuminareStepperAlignment
    public typealias Direction = LuminareStepperDirection
    public typealias Source = LuminareStepperSource<V>
    public typealias ProminentIndicators = LuminareStepperProminentIndicators<Modifier, V>
    
    @Environment(\.luminareAnimationFast) private var animationFast
    
    @Binding private var value: V
    private let source: Source
    
    private let alignment: Alignment
    private let direction: Direction
    private let indicatorSpacing: CGFloat
    private let maxSize: CGFloat
    private let margin: CGFloat
    
    private let hasHierarchy: Bool
    private let hasMask: Bool
    private let hasBlur: Bool
    
    private let prominentIndicators: ProminentIndicators
    private let feedback: (V) -> SensoryFeedback?
    
    @State private var containerSize: CGSize = .zero
    @State private var offset: CGFloat = .zero
    
    @State private var diff: Int = 0
    @State private var roundedValue: V
    
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
        
        prominentIndicators: ProminentIndicators,
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
        
        self.roundedValue = value.wrappedValue
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
        
        feedback: @escaping (V) -> SensoryFeedback? = { _ in .alignment }
    ) where Modifier == AnyView {
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
            
            prominentIndicators: .init(),
            feedback: feedback
        )
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
        
        prominentValues: [V],
        @ViewBuilder prominentModifier: @escaping (V, AnyView) -> Modifier,
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
            
            prominentIndicators: .init(values: prominentValues, modifier: prominentModifier),
            feedback: feedback
        )
    }
    
    public var body: some View {
        direction.stack(spacing: indicatorSpacing) {
            ForEach(0..<indicatorCount, id: \.self) { index in
                indicator(at: index)
            }
        }
        .frame(minWidth: minFrame.width, minHeight: minFrame.height)
        .frame(maxWidth: maxFrame.width, maxHeight: maxFrame.height)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { oldValue, newValue in
            containerSize = newValue
        }
        .mask(bleedingMask)
        .mask(visualMask)
        .overlay(content: scrollOverlay)
//        .gesture(
//            TapGesture()
//                .simultaneously(
//                    with:
//                        DragGesture(minimumDistance: 0)
//                        .onEnded { value in
//                            let cursorOffset = direction.offset(of: value.location)
//                            let nonAlternateShouldGrowth = cursorOffset > containerLength / 2
//                            let nonAlternateSign: CGFloat = nonAlternateShouldGrowth ? 1 : -1
//                            
//                            setValue(source.offsetBy(
//                                self.value,
//                                direction: direction,
//                                nonAlternateOffset: V(nonAlternateSign) * source.stride
//                            ))
//                        }
//                )
//        )
        .sensoryFeedback(trigger: roundedValue) { oldValue, newValue in
            guard oldValue != newValue else { return nil }
            return feedback(newValue)
        }
    }
    
    @ViewBuilder private func indicator(at index: Int) -> some View {
        let frame = direction.frame(0)
        let offsetFrame = direction.frame(-sigmoidOffset)
        let referencingValue = referencingValue(at: index)
        let isProminent = prominentIndicators.values.contains(referencingValue)
        
        Group {
            let frame = direction.frame(2)
            let sizeFactor = isProminent ? 1 : magnifyFactor(at: index)
            
            Color.clear
                .overlay {
                    Group {
                        if isProminent {
                            prominentIndicators.modifier(referencingValue, AnyView(
                                RoundedRectangle(cornerRadius: 1)))
                        } else {
                            RoundedRectangle(cornerRadius: 1)
                        }
                    }
                    .frame(width: frame.width, height: frame.height)
                    .foregroundStyle(.tint.opacity(hasHierarchy ? pow(0.5 + 0.5 * magnifyFactor(at: index), 2.0) : 1))
                }
                .padding(alignment.hardPaddingEdges(of: direction), margin)
                .padding(alignment.softPaddingEdges(of: direction), margin * (1 - sizeFactor))
                .blur(radius: hasBlur ? indicatorSpacing * blurFactor(at: index) : 0)
        }
        .frame(width: frame.width, height: frame.height)
        .offset(x: offsetFrame.width ?? 0, y: offsetFrame.height ?? 0)
    }
    
    @ViewBuilder private func bleedingMask() -> some View {
        if let count = source.count, let index = source.continuousIndex(of: value), source.isFinite {
            let indexSpanStart = max(0, CGFloat(centerIndicatorIndex) - 1 - CGFloat(index))
            let indexSpanEnd = max(0, CGFloat(centerIndicatorIndex) - 1 - (CGFloat(count) - 1 - CGFloat(index)))
            
            let offsetStart = source.reachedLowerBound(value) || source.reachedUpperBound(value) ? offset + indicatorSpacing : 0
            let offsetEnd = source.reachedLowerBound(value) || source.reachedUpperBound(value) ? -offset + indicatorSpacing : 0
            
            Color.white
                .padding(direction.paddingSpan.start, indexSpanStart * indicatorSpacing - offsetStart - 1)
                .padding(direction.paddingSpan.end, indexSpanEnd * indicatorSpacing - offsetEnd - 1)
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
                        wrapping: .init {
                            !source.isEdgeCase(value)
                        } set: { _ in
                            // do nothing
                        },
                        offset: $offset,
                        diff: $diff
                    )
                    .onChange(of: diff) { oldValue, newValue in
                        setRoundedValue(source.offsetBy(
                            roundedValue,
                            direction: direction,
                            nonAlternateOffset: V(newValue - oldValue) * source.stride
                        ))
                    }
                    .onChange(of: offset) { oldValue, newValue in
                        let offset = newValue / indicatorSpacing
                        let valueOffset = V(offset) * source.stride
                        setValue(source.offsetBy(
                            roundedValue,
                            direction: direction,
                            nonAlternateOffset: valueOffset.truncatingRemainder(dividingBy: source.stride)
                        ), sync: false)
                    }
                }
        }
    }
    
    private var indicatorOffset: CGFloat {
        if source.reachedUpperBound(value) {
            offset - indicatorSpacing
        } else if source.reachedLowerBound(value) {
            offset + indicatorSpacing
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
    
    private func setRoundedValue(_ newValue: V, sync: Bool = true) {
        let oldValue = roundedValue
        roundedValue = newValue
        if sync {
            value += newValue - oldValue
        }
    }
    
    private func setValue(_ newValue: V, sync: Bool = true) {
        value = newValue
        if sync {
            roundedValue = newValue - newValue.truncatingRemainder(dividingBy: source.stride)
        }
    }
    
    private func shift(at index: Int) -> CGFloat {
        CGFloat(centerIndicatorIndex - index) + sigmoidOffset / indicatorSpacing
    }
    
    private func referencingValue(at index: Int) -> V {
        let relativeIndex = index - centerIndicatorIndex
        return roundedValue + V(relativeIndex) * source.stride
    }
    
    private func magnifyFactor(at index: Int) -> CGFloat {
        let sd = 0.5
        let value = bellCurve(x: shift(at: index), standardDeviation: sd)
        let maxValue = bellCurve(x: 0, standardDeviation: sd)
        return value / maxValue
    }
    
    private func blurFactor(at index: Int) -> CGFloat {
        let sd = CGFloat(indicatorCount - 2)
        let value = bellCurve(x: shift(at: index), standardDeviation: sd)
        let maxValue = bellCurve(x: 0, standardDeviation: sd)
        return 1 - value / maxValue
    }
    
    /// Generates a bell curve value for a given x, mean, standard deviation, and amplitude.
    /// - Parameters:
    ///   - x: The x-value at which to evaluate the bell curve.
    ///   - mean: The mean (center) of the bell curve.
    ///   - standardDeviation: The standard deviation (width) of the bell curve. Higher values result in a wider curve.
    ///   - amplitude: The peak (height) of the bell curve.
    /// - Returns: The y-value of the bell curve at the given x.
    func bellCurve(x: CGFloat, mean: CGFloat = .zero, standardDeviation: CGFloat, amplitude: CGFloat = 1) -> CGFloat {
        let exponent = -pow(x - mean, 2) / (2 * pow(standardDeviation, 2))
        return amplitude * exp(exponent)
    }
    
    /// Sigmoid-like function that bends the input curve around 0.5.
    /// - Parameters:
    ///   - x: The input value, expected to be in the range [0, 1].
    ///   - curvature: A parameter to control the curvature. Higher values create a sharper bend.
    /// - Returns: The transformed output in the range [0, 1].
    func bentSigmoid(_ x: Double, curvature: Double = 7.5) -> Double {
        guard x >= -1 && x <= 1 else { return x }
        
        return if x >= 0 {
            1 / (1 + exp(-curvature * (x - 0.5)))
        } else {
            -bentSigmoid(-x)
        }
    }
}

//@available(macOS 15.0, *)
//struct SteppingScrollTargetBehavior: ScrollTargetBehavior {
//    var spacing: CGFloat?
//    var direction: LuminareStepperDirection
//    
//    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
//        if let spacing {
//            target.rect.origin.x -= target.rect.origin.x.remainder(dividingBy: spacing)
//            target.rect.origin.y -= target.rect.origin.y.remainder(dividingBy: spacing)
//        }
//    }
//}

@available(macOS 15.0, *)
private struct StepperPreview: View {
    @State private var value: CGFloat = 42
    
    var body: some View {
        LuminareStepperView(
            value: $value,
            source: .finite(range: -100...50, stride: 2),
            prominentValues: [42]
        ) { _, view in
            view.tint(.accentColor)
        }
        .tint(.primary)
        
        Text(String(format: "%.1f", value))
    }
}

@available(macOS 15.0, *)
#Preview {
    LuminareSection {
        StepperPreview()
    }
    .padding()
}
