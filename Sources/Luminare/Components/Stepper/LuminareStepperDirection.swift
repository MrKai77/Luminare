//
//  LuminareStepperDirection.swift
//  Luminare
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

/// The direction of a ``LuminareStepper``.
@available(macOS 15.0, *)
public enum LuminareStepperDirection: String, Equatable, Hashable, Identifiable, CaseIterable, Codable, Sendable {
    /// In left-to-right layouts, the larger values are right-sided.
    case horizontal
    /// In left-to-right layouts, the larger values are left-sided.
    case horizontalAlternate
    /// In left-to-right layouts, the larger values are upward.
    case vertical
    /// In left-to-right layouts, the larger values are downward.
    case verticalAlternate

    public var id: Self { self }

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
