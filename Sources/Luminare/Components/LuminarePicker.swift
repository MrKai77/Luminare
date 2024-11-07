//
//  LuminarePicker.swift
//
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

public protocol LuminarePickerData {
    var selectable: Bool { get }
}

// MARK: - Picker

public struct LuminarePicker<Content, V>: View
where Content: View, V: Equatable {
    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation

    // MARK: Fields

    private let cornerRadius: CGFloat = 12, innerPadding: CGFloat = 4, innerCornerRadius: CGFloat = 2

    private let elements2D: [[V]]
    private let rowsIndex: Int, columnsIndex: Int

    @Binding private var selectedItem: V
    @State private var internalSelection: V

    private let roundTop: Bool, roundBottom: Bool

    @ViewBuilder private let content: (V) -> Content

    // MARK: Initializers

    public init(
        elements: [V],
        selection: Binding<V>,
        columns: Int = 4,
        roundTop: Bool = true,
        roundBottom: Bool = true,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.elements2D = elements.slice(size: columns)
        self.rowsIndex = elements2D.count - 1
        self.columnsIndex = columns - 1
        self.roundTop = roundTop
        self.roundBottom = roundBottom
        self.content = content

        self._selectedItem = selection
        self._internalSelection = State(initialValue: selection.wrappedValue)
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
        (element as? LuminarePickerData)?.selectable == false
    }

    private func getElement(row: Int, column: Int) -> V? {
        guard column < elements2D[row].count else { return nil }
        return elements2D[row][column]
    }

    private func getShape(row: Int, column: Int) -> some InsettableShape {
        // top left
        if column == 0, row == 0, roundTop {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: (rowsIndex == 0 && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: (columnsIndex == 0) ? cornerRadius - innerPadding : innerCornerRadius
            )
        }

        // bottom left
        else if column == 0, row == rowsIndex, roundBottom {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: (columnsIndex == 0) ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }

        // top right
        else if column == columnsIndex, row == 0, roundTop {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: (rowsIndex == 0 && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        }

        // bottom right
        else if column == columnsIndex, row == rowsIndex, roundBottom {
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

#Preview("LuminarePicker") {
    LuminareSection {
        LuminarePicker(
            elements: Array(32..<50),
            selection: .constant(42)
        ) { num in
            Text("\(num)")
        }
    }
    .padding()
}
