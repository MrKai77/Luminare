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

public struct LuminarePicker<Content, V>: View 
where Content: View, V: Equatable {
    @Environment(\.luminareAnimation) private var animation
    
    private let cornerRadius: CGFloat = 12
    private let innerPadding: CGFloat = 4
    private let innerCornerRadius: CGFloat = 2

    private let elements2D: [[V]]
    private let rowsIndex: Int
    private let columnsIndex: Int

    @Binding private var selectedItem: V
    @State private var internalSelection: V

    private let roundTop: Bool
    private let roundBottom: Bool
    
    @ViewBuilder private let content: (V) -> Content

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
        // this improves animation performance
        .onChange(of: internalSelection) { _ in
            withAnimation(animation) {
                selectedItem = internalSelection
            }
        }
        .buttonStyle(LuminareButtonStyle())
    }

    @ViewBuilder func pickerButton(i: Int, j: Int) -> some View {
        if let element = getElement(i: i, j: j) {
            Button {
                guard !isDisabled(element) else { return }
                withAnimation(animation) {
                    internalSelection = element
                }
            } label: {
                ZStack {
                    let isActive = internalSelection == element
                    getShape(i: i, j: j)
                        .foregroundStyle(isActive ? AnyShapeStyle(.tint.opacity(0.15)) : AnyShapeStyle(.clear))
                        .overlay {
                            getShape(i: i, j: j)
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
        // top left
        if j == 0, i == 0, roundTop {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius - innerPadding,
                bottomLeadingRadius: (rowsIndex == 0 && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                bottomTrailingRadius: innerCornerRadius,
                topTrailingRadius: (columnsIndex == 0) ? cornerRadius - innerPadding : innerCornerRadius
            )
        }
        // bottom left
        else if j == 0, i == rowsIndex, roundBottom {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: cornerRadius - innerPadding,
                bottomTrailingRadius: (columnsIndex == 0) ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: innerCornerRadius
            )
        }
        // top right
        else if j == columnsIndex, i == 0, roundTop {
            UnevenRoundedRectangle(
                topLeadingRadius: innerCornerRadius,
                bottomLeadingRadius: innerCornerRadius,
                bottomTrailingRadius: (rowsIndex == 0 && roundBottom) ? cornerRadius - innerPadding : innerCornerRadius,
                topTrailingRadius: cornerRadius - innerPadding
            )
        }
        // bottom right
        else if j == columnsIndex, i == rowsIndex, roundBottom {
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

extension Array {
    func slice(size: Int) -> [[Element]] {
        (0 ..< (count / size + (count % size == 0 ? 0 : 1)))
            .map {
                Array(self[($0 * size) ..< (Swift.min($0 * size + size, count))])
            }
    }
}

#Preview {
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
