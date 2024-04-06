//
//  LuminarePicker.swift
//  
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

public struct LuminarePickerData: Identifiable, Equatable {
    public var id: UUID = UUID()

    let text: String
    let image: Image?
    let subtitle: String?

    public init(text: String, image: Image? = nil, subtitle: String? = nil) {
        self.image = image
        self.text = text
        self.subtitle = subtitle
    }
}

public struct LuminarePicker: View {
    @Environment(\.tintColor) var tintColor

    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    let elements2D: [[LuminarePickerData]]
    let rowsIndex: Int
    let columnsIndex: Int
    @Binding var selectedItem: LuminarePickerData

    public init(
        elements: [LuminarePickerData],
        selection: Binding<LuminarePickerData>,
        columns: Int = 4
    ) {
        self.elements2D = elements.slice(size: columns)
        self.rowsIndex = self.elements2D.count - 1
        self.columnsIndex = columns - 1
        self._selectedItem = selection
    }

    public var body: some View {
        Group {
            if rowsIndex == 0 {
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
                                    .aspectRatio(1, contentMode: .fit)
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
                let row = self.elements2D[i]

                // There are also trailing blank items in the grid, so check if it exists
                if j < row.count {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.selectedItem = row[j]
                    }
                }
            } label: {
                ZStack {
                    VStack {
                        if let image = element.image {
                            image
                        }

                        Text(element.text)

                        if let subtitle = element.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
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

    func getElement(i: Int, j: Int) -> LuminarePickerData? {
        let row = self.elements2D[i]
        guard j < row.count else { return nil }
        return self.elements2D[i][j]
    }

    func isSelfActive(i: Int, j: Int) -> Bool {
        guard let element = getElement(i: i, j: j) else { return false }
        return self.selectedItem == element
    }

    func getShape(i: Int, j: Int) -> some InsettableShape {
        if j == 0 && i == 0 {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: rowsIndex == 0 ? cornerRadius - innerPadding : innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        } else if j == 0 && i == rowsIndex {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        } else if j == columnsIndex && i == 0 {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: rowsIndex == 0 ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        } else if j == columnsIndex && i == rowsIndex {
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
