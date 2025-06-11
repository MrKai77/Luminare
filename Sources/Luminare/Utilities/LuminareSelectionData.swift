//
//  LuminareSelectionData.swift
//  Luminare
//
//  Created by KrLite on 2024/11/10.
//

import SwiftUI

/// The selection's behavior.
///
/// Suitable for customizing selection appearance in certain views.
///
/// - **Currently used in:**
///   - ``LuminareList``
///   - ``LuminarePicker``
public protocol LuminareSelectionData {
    /// Whether this element is selectable.
    var isSelectable: Bool { get }
}

public extension LuminareSelectionData {
    var isSelectable: Bool { true }
}
