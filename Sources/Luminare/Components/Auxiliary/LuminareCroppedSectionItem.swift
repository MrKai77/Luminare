//
//  LuminareCroppedSectionItem.swift
//  
//
//  Created by KrLite on 2024/11/15.
//

import SwiftUI

// MARK: - Cropped Section Item

/// An item with a cropped appearance, typically used in sections.
public struct LuminareCroppedSectionItem: ViewModifier {
    // MARK: Fields
    
    private let innerPadding: CGFloat
    private let cornerRadius: CGFloat, buttonCornerRadius: CGFloat
    private let isFirstChild: Bool, isLastChild: Bool
    
    // MARK: Initializers
    
    /// Initializes a ``LuminareCroppedItem``.
    ///
    /// - Parameters:
    ///   - innerPadding: the padding around the contents.
    ///   - cornerRadius: the radius of the corners.
    ///   - buttonCornerRadius: the corner radius of the button.
    ///   - isFirstChild: whether this item is the first of the section.
    ///   - isLastChild: whether this item is the last of the section.
    public init(
        innerPadding: CGFloat = 4,
        cornerRadius: CGFloat = 12, buttonCornerRadius: CGFloat = 2,
        isFirstChild: Bool, isLastChild: Bool
    ) {
        self.innerPadding = innerPadding
        self.cornerRadius = cornerRadius
        self.buttonCornerRadius = buttonCornerRadius
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
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if isFirstChild {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: buttonCornerRadius,
                bottomTrailingRadius: buttonCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if isLastChild {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: buttonCornerRadius
            )
        } else {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadius,
                bottomLeadingRadius: buttonCornerRadius,
                bottomTrailingRadius: buttonCornerRadius,
                topTrailingRadius: buttonCornerRadius
            )
        }
    }
}
