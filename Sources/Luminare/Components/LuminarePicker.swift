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
    @Binding var selectedItem: V?

    let roundTop: Bool
    let roundBottom: Bool
    let content: (V) -> Content

    public init(
        elements: [V],
        selection: Binding<V?>,
        columns: Int = 4,
        roundTop: Bool = true,
        roundBottom: Bool = true,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.elements2D = elements.slice(size: columns)
        self.rowsIndex = self.elements2D.count - 1
        self.columnsIndex = columns - 1
        self._selectedItem = selection
        self.roundTop = roundTop
        self.roundBottom = roundBottom
        self.content = content
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
    }

    @ViewBuilder func pickerButton(i: Int, j: Int) -> some View {
        if let element = self.getElement(i: i, j: j) {
            Button {
                if let element = element as? LuminarePickerData {
                    guard element.selectable else { return }
                }

                let row = self.elements2D[i]

                // There are also trailing blank items in the grid, so check if it exists
                if j < row.count {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.selectedItem = row[j]
                    }
                }
            } label: {
                ZStack {
                    self.content(element)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    let isActive = isSelfActive(i: i, j: j)
                    getShape(i: i, j: j)
                        .foregroundStyle(isActive ? tintColor.opacity(0.15) : .clear)
                        .overlay {
                            getShape(i: i, j: j)
                                .strokeBorder(
                                    tintColor,
                                    lineWidth: isActive ? 1.5 : 0
                                )
                        }
                }
            }
        } else {
            getShape(i: i, j: j)
                .strokeBorder(
                    .quaternary,
                    lineWidth: 1
                )
        }
    }

    func getElement(i: Int, j: Int) -> V? {
        let row = self.elements2D[i]
        guard j < row.count else { return nil }
        return self.elements2D[i][j]
    }

    func isSelfActive(i: Int, j: Int) -> Bool {
        guard let element = getElement(i: i, j: j) else { return false }
        return self.selectedItem == element
    }

    func getShape(i: Int, j: Int) -> some InsettableShape {
        if j == 0 && i == 0 && roundTop { // Top left
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: (rowsIndex == 0 && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: (columnsIndex == 0) ?  cornerRadius - innerPadding : innerCornerRadius
            )
        } else if j == 0 && i == rowsIndex && roundBottom { // Bottom left
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: (columnsIndex == 0) ?  cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        } else if j == columnsIndex && i == 0 && roundTop { // Top right
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: (rowsIndex == 0 && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if j == columnsIndex && i == rowsIndex && roundBottom { // Bottom right
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: cornerRadius - innerPadding,
                topTrailingRadius: innerCornerRadius
            )
        } else {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }
    }
}

extension Array {
   func slice(size: Int) -> [[Element]] {
       (0..<(count / size + (count % size == 0 ? 0 : 1))).map{
           Array(self[($0 * size)..<(Swift.min($0 * size + size, count))])
       }
   }
}
