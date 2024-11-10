//
//  LuminarePicker.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

/// Defines the element's behaviors inside a ``LuminarePicker``.
public protocol LuminarePickerData {
    /// Whether this element is selectable.
    var isSelectable: Bool { get }
}

// MARK: - Picker

/// A stylized, grid based picker.
public struct LuminarePicker<Content, V>: View where Content: View, V: Equatable {
    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation

    // MARK: Fields

    private let cornerRadius: CGFloat, innerPadding: CGFloat, innerCornerRadius: CGFloat

    private let elements2D: [[V]]
    private let rowsIndex: Int, columnsIndex: Int

    @Binding private var selectedItem: V
    @State private var internalSelection: V

    private let roundedTop: Bool, roundedBottom: Bool

    @ViewBuilder private let content: (V) -> Content

    // MARK: Initializers

    /// Initializes a ``LuminarePicker``.
    ///
    /// - Parameters:
    ///   - elements: the selectable elements.
    ///   - selection: the binding of the selected value.
    ///   - columns: the columns of the grid.
    ///   - roundedTop: whether to have top corners rounded.
    ///   - roundedBottom: whether to have bottom corners rounded.
    ///   - cornerRadius: the radius of the corners.
    ///   - innerPadding: the padding between the buttons.
    ///   - innerCornerRadius: the radius of the corners of the buttons.
    ///   - content: the content generator that accepts a value.
    public init(
        elements: [V],
        selection: Binding<V>,
        columns: Int = 4,
        roundedTop: Bool = true, roundedBottom: Bool = true,
        cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4, innerCornerRadius: CGFloat = 2,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.elements2D = elements.slice(size: columns)
        self.rowsIndex = elements2D.count - 1
        self.columnsIndex = columns - 1
        self.roundedTop = roundedTop
        self.roundedBottom = roundedBottom
        self.cornerRadius = cornerRadius
        self.innerPadding = innerPadding
        self.innerCornerRadius = innerCornerRadius
        self.content = content

        self._selectedItem = selection
        self.internalSelection = selection.wrappedValue
    }

    // MARK: Body

    public var body: some View {
        Group {
            if isCompact {
                HStack(spacing: 2) {
                    ForEach(0...columnsIndex, id: \.self) { column in
                        pickerButton(row: 0, column: column)
                    }
                }
                .frame(minHeight: 34)
            } else {
                VStack(spacing: 2) {
                    ForEach(0...rowsIndex, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0...columnsIndex, id: \.self) { column in
                                pickerButton(row: row, column: column)
                            }
                        }
                    }
                }
                .frame(minHeight: 150)
            }
        }
        // this improves animation performance
        .onChange(of: internalSelection) { _ in
            withAnimation(animation) {
                selectedItem = internalSelection
            }
        }
        .buttonStyle(LuminareButtonStyle())
    }

    @ViewBuilder private func pickerButton(row: Int, column: Int) -> some View {
        if let element = getElement(row: row, column: column) {
            Button {
                guard !isDisabled(element) else { return }
                withAnimation(animation) {
                    internalSelection = element
                }
            } label: {
                ZStack {
                    let isActive = internalSelection == element
                    getShape(row: row, column: column)
                        .foregroundStyle(isActive ? AnyShapeStyle(.tint.opacity(0.15)) : AnyShapeStyle(.clear))
                        .overlay {
                            getShape(row: row, column: column)
                                .strokeBorder(
                                    .tint,
                                    lineWidth: isActive ? 1.5 : 0
                                )
                        }

                    content(element)
                        .foregroundStyle(isDisabled(element) ? .secondary : .primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        } else {
            getShape(row: row, column: column)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }

    private var isCompact: Bool {
        rowsIndex == 0
    }

    // MARK: Functions

    private func isDisabled(_ element: V) -> Bool {
        (element as? LuminarePickerData)?.isSelectable == false
    }

    private func getElement(row: Int, column: Int) -> V? {
        guard column < elements2D[row].count else { return nil }
        return elements2D[row][column]
    }

    private func getShape(row: Int, column: Int) -> some InsettableShape {
        // top left
        if column == 0, row == 0, roundedTop {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: (rowsIndex == 0 && roundedBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: (columnsIndex == 0) ? cornerRadius - innerPadding : innerCornerRadius
            )
        }

        // bottom left
        else if column == 0, row == rowsIndex, roundedBottom {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: (columnsIndex == 0) ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }

        // top right
        else if column == columnsIndex, row == 0, roundedTop {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: (rowsIndex == 0 && roundedBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        }

        // bottom right
        else if column == columnsIndex, row == rowsIndex, roundedBottom {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: innerCornerRadius
            )
        }

        // regular
        else {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminarePicker",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var selection = 42

    LuminareSection {
        LuminarePicker(
            elements: Array(32..<50),
            selection: $selection
        ) { num in
            Text("\(num)")
        }
    }
}
