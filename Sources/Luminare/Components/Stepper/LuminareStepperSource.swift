//
//  LuminareStepperSource.swift
//  Luminare
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

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
    case finite(in: ClosedRange<V>, step: V = 1)
    /// The value is finely ranged but continuous.
    ///
    /// The value will be strictly clamped inside a closed range, but won't be snapped.
    ///
    /// In this case, the step only defines how many values are between two indicators.
    ///
    /// - Parameters:
    ///   - in: the closed range of the available values.
    ///   - step: the step between two indicators.
    case finiteContinuous(in: ClosedRange<V>, step: V = 1)
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

    public static var infinite: Self {
        .infinite()
    }

    public static var infiniteContinuous: Self {
        .infiniteContinuous()
    }

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
        case let .finite(range, step), let .finiteContinuous(range, step):
            Int(((range.upperBound - range.lowerBound) / step).rounded(.down)) + 1
        default:
            nil
        }
    }

    var total: V? {
        switch self {
        case let .finite(range, _), let .finiteContinuous(range, _):
            range.upperBound - range.lowerBound
        case .infinite, .infiniteContinuous:
            nil
        }
    }

    var step: V {
        switch self {
        case let .finite(_, step), let .finiteContinuous(_, step),
             let .infinite(step), let .infiniteContinuous(step):
            step
        }
    }

    func round(_ value: V) -> (value: V, offset: V) {
        switch self {
        case let .finite(range, step), let .finiteContinuous(range, step):
            let page = value - range.lowerBound
            let remainder = page.truncatingRemainder(dividingBy: step)
            return (value - remainder, remainder)
        case let .infinite(step), let .infiniteContinuous(step):
            let remainder = value.truncatingRemainder(dividingBy: step)
            return (value - remainder, remainder)
        }
    }

    func continuousIndex(of value: V) -> V? {
        switch self {
        case let .finite(range, step), let .finiteContinuous(range, step):
            (value - range.lowerBound) / step
        default:
            nil
        }
    }

    func isEdgeCase(_ value: V) -> Bool {
        switch self {
        case let .finite(range, step), let .finiteContinuous(range, step):
            let min = range.lowerBound + step
            let max = range.upperBound - step

            return value < min || value > max
        case .infinite, .infiniteContinuous:
            return false
        }
    }

    func reachedUpperBound(_ value: V, padding: V = .zero) -> Bool {
        switch self {
        case let .finite(range, _), let .finiteContinuous(range, _):
            value + padding >= range.upperBound
        case .infinite, .infiniteContinuous:
            false
        }
    }

    func reachedLowerBound(_ value: V, padding: V = .zero) -> Bool {
        switch self {
        case let .finite(range, _), let .finiteContinuous(range, _):
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
        case let .finite(range, _), let .finiteContinuous(range, _):
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
