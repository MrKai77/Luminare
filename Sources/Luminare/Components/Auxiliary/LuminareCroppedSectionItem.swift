//
//  LuminareCroppedSectionItem.swift
//  Luminare
//
//  Created by KrLite on 2024/11/15.
//

import SwiftUI

// MARK: - Cropped Section Item

/// An item with a cropped appearance, typically used in sections.
public struct LuminareCroppedSectionItem: ViewModifier {
    // MARK: Environments

    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareButtonCornerRadii) private var buttonCornerRadii

    // MARK: Fields

    private let innerPadding: CGFloat
    private let isFirstChild: Bool, isLastChild: Bool

    // MARK: Initializers

    /// Initializes a ``LuminareCroppedItem``.
    ///
    /// - Parameters:
    ///   - innerPadding: the padding around the contents.
    ///   - isFirstChild: whether this item is the first of the section.
    ///   - isLastChild: whether this item is the last of the section.
    public init(
        innerPadding: CGFloat = 4,
        isFirstChild: Bool, isLastChild: Bool
    ) {
        self.innerPadding = innerPadding
        self.isFirstChild = isFirstChild
        self.isLastChild = isLastChild
    }

    // MARK: Body

    public func body(content: Content) -> some View {
        content
            .mask(mask())
            .padding(.horizontal, innerPadding)
    }

    @ViewBuilder private func mask() -> some View {
        if isFirstChild, isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadii.topLeading - innerPadding,
                bottomLeadingRadius: cornerRadii.bottomLeading - innerPadding,
                bottomTrailingRadius: cornerRadii.bottomTrailing - innerPadding,
                topTrailingRadius: cornerRadii.topTrailing - innerPadding
            )
        } else if isFirstChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadii.topLeading - innerPadding,
                bottomLeadingRadius: buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: buttonCornerRadii.bottomTrailing,
                topTrailingRadius: cornerRadii.topTrailing - innerPadding
            )
        } else if isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: cornerRadii.bottomLeading - innerPadding,
                bottomTrailingRadius: cornerRadii.bottomTrailing - innerPadding,
                topTrailingRadius: buttonCornerRadii.topTrailing
            )
        } else {
            Rectangle()
        }
    }
}
