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
    
    func paddingEdges(of direction: LuminareStepperDirection) -> Edge.Set {
        switch self {
        case .none:
            []
        default:
            switch direction {
            case .horizontal, .horizontalAlternate:
                    .vertical
            case .vertical, .verticalAlternate:
                    .horizontal
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
    
    func position(of point: CGPoint) -> CGFloat {
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
    
    private let alignment: Alignment = .centered
    private let direction: Direction = .horizontal
    private let indicatorSpacing: CGFloat = 25
    private let maxSize: CGFloat = 70
    private let padding: CGFloat = 8
    
    @State private var length: CGFloat = 1000
    @State private var containerSize: CGSize = .zero
    @State private var offset: CGPoint = .zero
    
    var body: some View {
        direction.stack(spacing: indicatorSpacing) {
            ForEach(0..<indicatorCount, id: \.self) { index in
                let frame = direction.frame(0)
                
                Group {
                    let frame = direction.frame(2)
                    
                    if index == centerIndicatorIndex {
                        Color.clear
                            .overlay {
                                RoundedRectangle(cornerRadius: 1)
                                    .frame(width: frame.width, height: frame.height)
                                    .foregroundStyle(.primary)
                            }
                    } else {
                        Color.clear
                            .overlay {
                                RoundedRectangle(cornerRadius: 1)
                                    .frame(width: frame.width, height: frame.height)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(alignment.paddingEdges(of: direction), padding)
                    }
                }
                .frame(width: frame.width, height: frame.height)
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
                offset = newValue
            }
        }
        .frame(minWidth: minFrame.width, minHeight: minFrame.height)
        .frame(maxWidth: maxFrame.width, maxHeight: maxFrame.height)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { oldValue, newValue in
            containerSize = newValue
        }
        .onChange(of: offset) { _ in
            print(percentage)
        }
        .onChange(of: indicatorCount) { count in
            print(count)
        }
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
    
    private var position: CGFloat {
        direction.position(of: offset)
    }
    
    private var percentage: CGFloat {
        direction.percentage(in: length, at: position)
    }
}

@available(macOS 15.0, *)
#Preview {
    LuminareSection {
        LuminareStepperView()
    }
    .padding()
}
