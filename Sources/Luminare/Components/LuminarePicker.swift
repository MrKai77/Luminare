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

public struct LuminarePicker<Content, V>: View where Content: View, V: Equatable {
    @Environment(\.tintColor) var tintColor

    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    let elements2D: [[V]]
    let rowsIndex: Int
    let columnsIndex: Int

    @Binding var selectedItem: V

    let roundTop: Bool
    let roundBottom: Bool
    let content: (V) -> Content

    public init(
        elements: [V],
        selection: Binding<V>,
        columns: Int = 4,
        roundTop: Bool = true,
        roundBottom: Bool = true,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.elements2D = elements.slice(size: columns)
        self.rowsIndex = self.elements2D.count - 1
        self.columnsIndex = columns - 1
        self.roundTop = roundTop
        self.roundBottom = roundBottom
        self.content = content
        self._selectedItem = selection
    }

    var isCompact: Bool {
        rowsIndex == 0
    }

    public var body: some View {
        Group {
            if isCompact {
                HStack(spacing: 2) {
                    ForEach(0...columnsIndex, id: \.self) { j in
                        pickerButton(i: 0, j: j)
                    }
                }
                .frame(minHeight: 34)
            } else {
                VStack(spacing: 2) {
                    ForEach(0...rowsIndex, id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(0...columnsIndex, id: \.self) { j in
                                pickerButton(i: i, j: j)
                            }
                        }
                    }
                }
                .frame(minHeight: 150)
            }
        }
        .onChange(of: selectedItem) { newValue in
            selectedItem = newValue
        }
    }

    @ViewBuilder func pickerButton(i: Int, j: Int) -> some View {
        if let element = getElement(i: i, j: j) {
            Button {
                guard !isDisabled(element) else { return }
                selectedItem = element
            } label: {
                ZStack {
                    let isActive = selectedItem == element
                    getShape(i: i, j: j)
                        .foregroundStyle(isActive ? tintColor().opacity(0.15) : .clear)
                        .overlay {
                            getShape(i: i, j: j)
                                .strokeBorder(
                                    tintColor(),
                                    lineWidth: isActive ? 1.5 : 0
                                )
                        }

                    content(element)
                        .foregroundStyle(isDisabled(element) ? .secondary : .primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        } else {
            getShape(i: i, j: j)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }

    func isDisabled(_ element: V) -> Bool {
        (element as? LuminarePickerData)?.selectable == false
    }

    func getElement(i: Int, j: Int) -> V? {
        guard j < elements2D[i].count else { return nil }
        return elements2D[i][j]
    }

    func getShape(i: Int, j: Int) -> some InsettableShape {
        let topLeading = (i == 0 && j == 0 && roundTop) || (i == 0 && j == columnsIndex && roundTop) ? cornerRadius - innerPadding : innerCornerRadius
        let bottomLeading = (i == rowsIndex && j == 0 && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius
        let bottomTrailing = (i == rowsIndex && j == columnsIndex && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius
        let topTrailing = (i == 0 && j == columnsIndex && roundTop) ? cornerRadius - innerPadding : innerCornerRadius

        return UnevenRoundedRectangle(
            topLeadingRadius: topLeading,
            bottomLeadingRadius: bottomLeading,
            bottomTrailingRadius: bottomTrailing,
            topTrailingRadius: topTrailing
        )
    }
}

extension Array {
    func slice(size: Int) -> [[Element]] {
        (0..<(count / size + (count % size == 0 ? 0 : 1))).map {
            Array(self[($0 * size)..<(Swift.min($0 * size + size, count))])
        }
    }
}
