//
//  LuminarePicker.swift
//  
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

public struct LuminarePickerData<Content>: Identifiable where Content: View {
    let view: () -> Content
    public let id: UUID = UUID()

    public init(@ViewBuilder view: @escaping () -> Content) {
        self.view = view
    }

    static func == (lhs: LuminarePickerData<Content>, rhs: LuminarePickerData<Content>) -> Bool {
        lhs.id == rhs.id
    }
}

public struct LuminarePicker<Content>: View where Content: View {

    let cornerRadius: CGFloat = 12
    let innerPadding: CGFloat = 4
    let innerCornerRadius: CGFloat = 2

    let elements2D: [[LuminarePickerData<Content>]]
    let rowsIndex: Int
    let columnsIndex: Int
    @State var selectedItem: LuminarePickerData<Content>

    public init(elements: [LuminarePickerData<Content>], columns: Int = 4) {
        self.elements2D = elements.slice(size: columns)
        self.rowsIndex = self.elements2D.count - 1
        self.columnsIndex = columns - 1
        self.selectedItem = elements[0]
    }

    public var body: some View {
        Group {
            if rowsIndex == 0 {
                HStack(spacing: 2) {
                    ForEach(0...columnsIndex, id: \.self) { j in
                        pickerButton(i: 0, j: j)
                    }
                }
                .frame(maxHeight: 150)
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
            }
        }
        .frame(minHeight: 100)
    }

    @ViewBuilder func pickerButton(i: Int, j: Int) -> some View {
        if let element = self.getElement(i: i, j: j) {
            Button {
                let row = self.elements2D[i]

                // There are also trailing blank items in the grid, so check if it exists
                if j < row.count {
                    withAnimation(.easeInOut) {
                        self.selectedItem = row[j]
                    }
                }
            } label: {
                element.view()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    .background {
                        getShape(i: i, j: j)
                            .foregroundStyle(.quinary)
                            .overlay {
                                getShape(i: i, j: j)
                                    .strokeBorder(
                                        .yellow,
                                        lineWidth: isSelfActive(i: i, j: j) ? 2 : 0
                                    )
                                    .opacity(isSelfActive(i: i, j: j) ? 1 : 0.8)
                            }
                    }
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            getShape(i: i, j: j)
                .strokeBorder(
                    .quaternary,
                    lineWidth: 1
                )
        }
    }

    func getElement(i: Int, j: Int) -> LuminarePickerData<Content>? {
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
