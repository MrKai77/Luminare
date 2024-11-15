//
//  LuminareCompose.swift
//  
//
//  Created by KrLite on 2024/10/25.
//

import SwiftUI

// MARK: - Compose

/// A stylized view that composes a content with a label.
public struct LuminareCompose<Label, Content>: View where Label: View, Content: View {
    // MARK: Environments

    @Environment(\.isEnabled) private var isEnabled

    // MARK: Fields

    let elementMinHeight: CGFloat, horizontalPadding: CGFloat
    let reducesTrailingSpace: Bool
    let spacing: CGFloat?

    @ViewBuilder private let content: () -> Content, label: () -> Label

    // MARK: Initializers

    /// Initializes a ``LuminareCompose``.
    ///
    /// - Parameters:
    ///   - elementMinHeight: the minimum height of the composed view.
    ///   - horizontalPadding: the horizontal padding around the composed content.
    ///   - reducesTrailingSpace: whether to reduce the trailing space to specially optimize for buttons and switches.
    ///   Typically, reducing trailing spaces will work better with contents with borders, as this behavior unifies the
    ///   padding around the content.
    ///   - spacing: the spacing between the label and the content.
    ///   - content: the content.
    ///   - label: the label.
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        reducesTrailingSpace: Bool = false,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.reducesTrailingSpace = reducesTrailingSpace
        self.spacing = spacing
        self.label = label
        self.content = content
    }

    /// Initializes a ``LuminareCompose`` where the label is a localized text.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the label text.
    ///   - elementMinHeight: the minimum height of the composed view.
    ///   - horizontalPadding: the horizontal padding around the composed content.
    ///   - reducesTrailingSpace: whether to reduce the trailing space to specially optimize for buttons and switches.
    ///   Typically, reducing trailing spaces will work better with contents with borders, as this behavior unifies the
    ///   padding around the content.
    ///   - spacing: the spacing between the label and the content.
    ///   - content: the content.
    public init(
        _ key: LocalizedStringKey,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        reducesTrailingSpace: Bool = false,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text {
        self.init(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            reducesTrailingSpace: reducesTrailingSpace,
            spacing: spacing
        ) {
            content()
        } label: {
            Text(key)
        }
    }

    // MARK: Body

    public var body: some View {
        HStack(spacing: spacing) {
            HStack(spacing: 0) {
                label()
                    .opacity(isEnabled ? 1 : 0.5)
                    .disabled(!isEnabled)
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer()

            content()
                .disabled(!isEnabled)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.trailing, reducesTrailingSpace ? -4 : 0)
        .frame(minHeight: elementMinHeight)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareCompose",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        LuminareCompose("Label", reducesTrailingSpace: true) {
            Button {

            } label: {
                Text("Button")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }

        LuminareCompose("Label", reducesTrailingSpace: true) {
            Button {

            } label: {
                Text("Button")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
        .disabled(true)
    }
}
