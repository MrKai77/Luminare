//
//  LuminareList+Initializers.swift
//  Luminare
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

public extension LuminareList {
    /// Initializes a ``LuminareList`` that displays literally nothing when nothing is inside the list.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - roundedTop: whether to have top corners rounded.
    ///   - roundedBottom: whether to have bottom corners rounded.
    ///   - content: the content generator that accepts a value binding.
    init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        roundedTop: Bool = false, roundedBottom: Bool = false,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
    ) where ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            roundedTop: roundedTop, roundedBottom: roundedBottom,
            content: content
        ) {
            EmptyView()
        }
    }
}
