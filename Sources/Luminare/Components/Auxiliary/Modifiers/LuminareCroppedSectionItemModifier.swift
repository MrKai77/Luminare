//
//  LuminareCroppedSectionItemModifier.swift
//  Luminare
//
//  Created by KrLite on 2024/11/15.
//

import SwiftUI

// MARK: - Cropped Section Item

/// An item with a cropped appearance, typically used in sections.
public struct LuminareCroppedSectionItemModifier: ViewModifier {
    // MARK: Environments

    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareButtonCornerRadii) private var buttonCornerRadii

    // MARK: Fields

    private let innerPadding: CGFloat
    private let isFirstChild: Bool
    private let isLastChild: Bool
    private let isEnabled: Bool

    // MARK: Initializers

    /// Initializes a ``LuminareCroppedItem``.
    ///
    /// - Parameters:
    ///   - innerPadding: the padding around the contents, used to calculate the corner radius.
    ///   - isFirstChild: whether this item is the first of the section.
    ///   - isLastChild: whether this item is the last of the section.
    ///   - isEnabled: whether to enable this mask.
    public init(
        innerPadding: CGFloat,
        isFirstChild: Bool,
        isLastChild: Bool,
        isEnabled: Bool
    ) {
        self.innerPadding = innerPadding
        self.isFirstChild = isFirstChild
        self.isLastChild = isLastChild
        self.isEnabled = isEnabled
    }

    // MARK: Body

    public func body(content: Content) -> some View {
        if isEnabled {
            content
                .clipShape(clipShape())
        } else {
            content
        }
    }

    private func clipShape() -> UnevenRoundedRectangle {
        /// Note all the `- 1` adjustments are to account for the 1px padding that is drawn by the `DividedVStackChildView`.
        /// This is because of the border that encompasses the entire `LuminareSection`.
        if isFirstChild, isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadii.topLeading - innerPadding,
                bottomLeadingRadius: cornerRadii.bottomLeading - innerPadding - 1,
                bottomTrailingRadius: cornerRadii.bottomTrailing - innerPadding - 1,
                topTrailingRadius: cornerRadii.topTrailing - innerPadding
            )
        } else if isFirstChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadii.topLeading - innerPadding - 1,
                bottomLeadingRadius: buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: buttonCornerRadii.bottomTrailing,
                topTrailingRadius: cornerRadii.topTrailing - innerPadding - 1
            )
        } else if isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: cornerRadii.bottomLeading - innerPadding - 1,
                bottomTrailingRadius: cornerRadii.bottomTrailing - innerPadding - 1,
                topTrailingRadius: buttonCornerRadii.topTrailing
            )
        } else {
            UnevenRoundedRectangle(cornerRadii: .init(0))
        }
    }
}
