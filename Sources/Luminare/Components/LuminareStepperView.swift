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
struct LuminareStepperView: View {
    public typealias Alignment = LuminareStepperAlignment
    public typealias Direction = LuminareStepperDirection
    
    private let alignment: Alignment = .trailing
    private let direction: Direction = .horizontal
    private let indicatorSpacing: CGFloat = 25
    private let maxSize: CGFloat = 70
    private let padding: CGFloat = 8
    private let hasMask: Bool = true
    
    @State private var containerSize: CGSize = .zero
    @State private var position: CGPoint = .zero
    
    var body: some View {
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
        .mask {
            let halfContainerLength = containerLength / 2
            Color.white
                .padding(direction.paddingSpan.start, max(0, halfContainerLength - offset() - 1))
                .padding(direction.paddingSpan.end, max(0, halfContainerLength - (length - offset()) - 1))
        }
        .mask {
            if hasMask{
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
        .overlay {
            ScrollView(.horizontal) {
                Color.clear
                    .frame(width: scrollableLength)
            }
            .onScrollGeometryChange(for: CGPoint.self) { proxy in
                proxy.contentOffset
            } action: { oldValue, newValue in
                position = newValue
            }
        }
        .onChange(of: position) { _ in
            print(percentage())
        }
    }
    
    @ViewBuilder private func indicator(at index: Int) -> some View {
        let frame = direction.frame(0)
        let offsetFrame = direction.frame(-indicatorOffset)
        
        Group {
            let frame = direction.frame(2)
            let magnifyFactor = magnifyFactor(at: index)
            
            Color.clear
                .overlay {
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: frame.width, height: frame.height)
                        .foregroundStyle(.secondary.opacity(pow(0.5 + 0.5 * magnifyFactor, 2.0)))
                }
                .padding(alignment.hardPaddingEdges(of: direction), padding)
                .padding(alignment.softPaddingEdges(of: direction), padding * (1 - magnifyFactor))
        }
        .frame(width: frame.width, height: frame.height)
        .offset(x: offsetFrame.width ?? 0, y: offsetFrame.height ?? 0)
    }
    
    private var length: CGFloat {
        1000
    }
    
    private var minFrame: (width: CGFloat?, height: CGFloat?) {
        direction.frame(3 * indicatorSpacing)
    }
    
    private var maxFrame: (width: CGFloat?, height: CGFloat?) {
        direction.frame(.infinity, fallback: maxSize)
    }
    
    private var overflowed: Bool {
        offset() < 0 || offset() > 1
    }
    
    private var indicatorCount: Int {
        let possibleCount = Int(floor(containerLength / indicatorSpacing))
        let oddCount = if possibleCount.isMultiple(of: 2) {
            possibleCount - 1
        } else {
            possibleCount
        }
        return max(3, oddCount)
    }
    
    private var centerIndicatorIndex: Int {
        indicatorCount.quotientAndRemainder(dividingBy: 2).quotient
    }
    
    private var containerLength: CGFloat {
        direction.length(of: containerSize)
    }
    
    private var scrollableLength: CGFloat {
        containerLength + length
    }
    
    private func offset(overflowing: Bool = true) -> CGFloat {
        let result = direction.offset(of: position)
        return if overflowing {
            result
        } else {
            max(0, min(length, result))
        }
    }
    
    private func percentage(overflowing: Bool = true) -> CGFloat {
        direction.percentage(in: length, at: offset(overflowing: overflowing))
    }
    
    private var indicatorOffset: CGFloat {
        offset().truncatingRemainder(dividingBy: indicatorSpacing)
    }
    
    private func magnifyFactor(at index: Int) -> CGFloat {
        let diff = CGFloat(centerIndicatorIndex - index) + indicatorOffset / indicatorSpacing
        return bellCurve(x: diff, standardDeviation: 1)
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
}

@available(macOS 15.0, *)
#Preview {
    LuminareSection {
        LuminareStepperView()
    }
    .padding()
}
