//
//  LuminarePicker.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - Picker

/// A stylized, grid based picker.
public struct LuminarePicker<Content, V>: View where Content: View, V: Equatable {
    // MARK: Environments

    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareCornerRadius) private var cornerRadius
    @Environment(\.luminareButtonCornerRadius) private var buttonCornerRadius

    // MARK: Fields

    private let innerPadding: CGFloat

    private let elements2D: [[V]]
    private let rows: Int, columns: Int

    @Binding private var selectedItem: V
    @State private var internalSelection: V

    private let roundedTop: Bool, roundedBottom: Bool

    @ViewBuilder private var content: (V) -> Content

    // MARK: Initializers

    /// Initializes a ``LuminarePicker``.
    ///
    /// - Parameters:
    ///   - elements: the selectable elements.
    ///   - selection: the binding of the selected value.
    ///   - columns: the columns of the grid.
    ///   - roundedTop: whether to have top corners rounded.
    ///   - roundedBottom: whether to have bottom corners rounded.
    ///   - innerPadding: the padding between the buttons.
    ///   - content: the content generator that accepts a value.
    public init(
        elements: [V],
        selection: Binding<V>,
        columns: Int = 4,
        roundedTop: Bool = true, roundedBottom: Bool = true,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.elements2D = elements.slice(size: columns)
        self.rows = elements2D.count
        self.columns = columns
        self.roundedTop = roundedTop
        self.roundedBottom = roundedBottom
        self.innerPadding = innerPadding
        self.content = content

        self._selectedItem = selection
        self.internalSelection = selection.wrappedValue
    }

    /// Initializes a ``LuminarePicker`` that is vertically compact, which has exactly 1 row of elements.
    ///
    /// - Parameters:
    ///   - compactElements: the selectable elements.
    ///   The columns of the picker will be aligned with the count of elements.
    ///   - selection: the binding of the selected value.
    ///   - roundedTop: whether to have top corners rounded.
    ///   - roundedBottom: whether to have bottom corners rounded.
    ///   - innerPadding: the padding between the buttons.
    ///   - content: the content generator that accepts a value.
    public init(
        compactElements: [V],
        selection: Binding<V>,
        roundedTop: Bool = true, roundedBottom: Bool = true,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.init(
            elements: compactElements,
            selection: selection,
            columns: compactElements.count,
            roundedTop: roundedTop, roundedBottom: roundedBottom,
            innerPadding: innerPadding,
            content: content
        )
    }

    // MARK: Body

    public var body: some View {
        Group {
            if isVerticallyCompact {
                HStack(spacing: 2) {
                    ForEach(0...maxColumnIndex, id: \.self) { column in
                        pickerButton(row: 0, column: column)
                    }
                }
                .frame(minHeight: 34)
            } else {
                VStack(spacing: 2) {
                    ForEach(0...maxRowIndex, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0...maxColumnIndex, id: \.self) { column in
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
        .buttonStyle(.luminare)
    }

    @ViewBuilder private func pickerButton(row: Int, column: Int) -> some View {
        if let element = getElement(row: row, column: column) {
            let isDisabled = isDisabled(element)
            let tint = tint(of: element)

            Button {
                withAnimation(animation) {
                    internalSelection = element
                }
            } label: {
                ZStack {
                    let isActive = internalSelection == element

                    getShape(row: row, column: column)
                        .foregroundStyle(.tint.opacity(isActive ? 0.15 : 0))
                        .overlay {
                            getShape(row: row, column: column)
                                .strokeBorder(
                                    .tint,
                                    lineWidth: isActive ? 1.5 : 0
                                )
                        }

                    content(element)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .disabled(isDisabled)
            .animation(animation, value: isDisabled)
            .overrideTint(tint)
        } else {
            getShape(row: row, column: column)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }

    private var isVerticallyCompact: Bool {
        rows == 1
    }

    private var isHorizontallyCompact: Bool {
        columns == 1
    }

    private var maxRowIndex: Int {
        rows - 1
    }

    private var maxColumnIndex: Int {
        columns - 1
    }

    // MARK: Functions

    private func isDisabled(_ element: V) -> Bool {
        (element as? LuminareSelectionData)?.isSelectable == false
    }

    private func tint(of element: V) -> Color {
        (element as? LuminareSelectionData)?.tint ?? tint
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
                bottomLeadingRadius:
                (isVerticallyCompact && roundedBottom) ? cornerRadius - innerPadding : buttonCornerRadius,
                bottomTrailingRadius: buttonCornerRadius,
                topTrailingRadius:
                isHorizontallyCompact ? cornerRadius - innerPadding : buttonCornerRadius
            )
        }

        // bottom left
        else if column == 0, row == maxRowIndex, roundedBottom {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius:
                isHorizontallyCompact ? cornerRadius - innerPadding : buttonCornerRadius,
                topTrailingRadius: buttonCornerRadius
            )
        }

        // top right
        else if column == maxColumnIndex, row == 0, roundedTop {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadius,
                bottomLeadingRadius: buttonCornerRadius,
                bottomTrailingRadius:
                (isHorizontallyCompact && roundedBottom) ? cornerRadius - innerPadding : buttonCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        }

        // bottom right
        else if column == maxColumnIndex, row == maxRowIndex, roundedBottom {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadius,
                bottomLeadingRadius: buttonCornerRadius,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: buttonCornerRadius
            )
        }

        // regular
        else {
            UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadius,
                bottomLeadingRadius: buttonCornerRadius,
                bottomTrailingRadius: buttonCornerRadius,
                topTrailingRadius: buttonCornerRadius
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
            elements: Array(32 ..< 50),
            selection: $selection
        ) { num in
            Text("\(num)")
        }
    }
}
