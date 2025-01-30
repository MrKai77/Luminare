//
//  LuminareStepperAlignment.swift
//  Luminare
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

/// The indicator alignment of a ``LuminareStepper``.
@available(macOS 15.0, *)
public enum LuminareStepperAlignment: String, Equatable, Hashable, Identifiable, CaseIterable, Codable, Sendable {
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
    case leading
    /// The center indicator is larger than others and points to the direction negatively normals to the
    /// ``LuminareStepperDirection``.
    ///
    /// In left-to-right layouts, the indicators point to bottom if ``LuminareStepperDirection`` is
    /// ``LuminareStepperDirection/horizontal`` and to right if ``LuminareStepperDirection`` is
    /// ``LuminareStepperDirection/vertical``.
    case trailing

    public var id: Self { self }

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
