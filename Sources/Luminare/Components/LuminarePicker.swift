//
//  LuminarePicker.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

// MARK: - Picker

/// A stylized, grid based picker.
public struct LuminarePicker<Content, V>: View where Content: View, V: Equatable {
    // MARK: Environments

    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.luminareTintColor) private var tintColor
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded

    let buttonCornerRadii: RectangleCornerRadii = .init(
        topLeading: 2,
        bottomLeading: 2,
        bottomTrailing: 2,
        topTrailing: 2
    )

    // MARK: Fields

    private let innerPadding: CGFloat

    private let elements2D: [[V]]
    private let rows: Int, columns: Int

    @Binding private var selectedItem: V
    @State private var internalSelection: V

    @ViewBuilder private var content: (V) -> Content

    // MARK: Initializers

    /// Initializes a ``LuminarePicker``.
    ///
    /// - Parameters:
    ///   - elements: the selectable elements.
    ///   - selection: the binding of the selected value.
    ///   - columns: the columns of the grid.
    ///   - innerPadding: the padding between the buttons.
    ///   - content: the content generator that accepts a value.
    public init(
        elements: [V],
        selection: Binding<V>,
        columns: Int = 4,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.elements2D = elements.slice(size: columns)
        self.rows = elements2D.count
        self.columns = columns
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
    ///   - innerPadding: the padding between the buttons.
    ///   - content: the content generator that accepts a value.
    public init(
        compactElements: [V],
        selection: Binding<V>,
        innerPadding: CGFloat = 4,
        @ViewBuilder content: @escaping (V) -> Content
    ) {
        self.init(
            elements: compactElements,
            selection: selection,
            columns: compactElements.count,
            innerPadding: innerPadding,
            content: content
        )
    }

    // MARK: Body

    public var body: some View {
        Group {
            if isVerticallyCompact {
                HStack(spacing: 4) {
                    ForEach(0...maxColumnIndex, id: \.self) { column in
                        pickerButton(row: 0, column: column)
                    }
                }
                .frame(minHeight: 34)
            } else {
                VStack(spacing: 4) {
                    ForEach(0...maxRowIndex, id: \.self) { row in
                        HStack(spacing: 4) {
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
            selectedItem = internalSelection
        }
        .onChange(of: selectedItem) { _ in
            withAnimation(animation) {
                internalSelection = selectedItem
            }
        }
        .buttonStyle(.luminare)
        .luminareTint(overridingWith: appearsActive ? tintColor : .disabledControlTextColor)
    }

    @ViewBuilder private func pickerButton(
        row: Int,
        column: Int
    ) -> some View {
        let shape = getShape(row: row, column: column)

        if let element = getElement(row: row, column: column) {
            let isDisabled = isDisabled(element)
            Button {
                guard !isDisabled else { return }

                withAnimation(animation) {
                    internalSelection = element
                }
            } label: {
                ZStack {
                    let isActive = internalSelection == element

                    shape
                        .foregroundStyle(.tint.opacity(isActive ? 0.15 : 0))
                        .overlay {
                            shape
                                .strokeBorder(
                                    .tint,
                                    lineWidth: isActive ? 1.5 : 0
                                )
                        }

                    content(element)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .opacity(isDisabled ? 0.5 : 1.0)
            .clipShape(shape)
            .animation(animation, value: isDisabled)
            .luminareRoundingBehavior(
                topLeading: row == 0 && column == 0 ? topLeadingRounded : false,
                topTrailing: row == 0 && column == maxColumnIndex ? topTrailingRounded : false,
                bottomLeading: row == maxRowIndex && column == 0 ? bottomLeadingRounded : false,
                bottomTrailing: row == maxRowIndex && column == maxColumnIndex ? bottomTrailingRounded : false
            )
        } else {
            shape
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

    private func getElement(row: Int, column: Int) -> V? {
        guard column < elements2D[row].count else { return nil }
        return elements2D[row][column]
    }

    private func getShape(row: Int, column: Int) -> some InsettableShape {
        // - Top leading

        if column == 0, row == 0 {
            return UnevenRoundedRectangle(
                topLeadingRadius: topLeadingRounded ? cornerRadii.topLeading - innerPadding : buttonCornerRadii.topLeading,
                bottomLeadingRadius: (isVerticallyCompact && bottomLeadingRounded) ? cornerRadii.bottomLeading - innerPadding : buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: buttonCornerRadii.bottomTrailing,
                topTrailingRadius: (isHorizontallyCompact && topTrailingRounded) ? cornerRadii.topTrailing - innerPadding : buttonCornerRadii.topTrailing
            )
        }

        // - Bottom leading

        else if column == 0, row == maxRowIndex {
            return UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: bottomLeadingRounded ? cornerRadii.bottomLeading - innerPadding : buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: buttonCornerRadii.bottomTrailing,
                topTrailingRadius: (isHorizontallyCompact && topTrailingRounded) ? cornerRadii.topTrailing - innerPadding : buttonCornerRadii.topTrailing
            )
        }

        // - Bottom trailing

        else if column == maxColumnIndex, row == maxRowIndex {
            return UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: bottomLeadingRounded ? cornerRadii.bottomTrailing - innerPadding : buttonCornerRadii.bottomTrailing,
                topTrailingRadius: (isVerticallyCompact && topTrailingRounded) ? cornerRadii.topTrailing - innerPadding : buttonCornerRadii.topTrailing
            )
        }

        // - Top trailing

        else if column == maxColumnIndex, row == 0 {
            return UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: (isHorizontallyCompact && bottomLeadingRounded) ? cornerRadii.bottomLeading - innerPadding : buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: (isHorizontallyCompact && bottomTrailingRounded) ? cornerRadii.bottomTrailing - innerPadding : buttonCornerRadii.bottomTrailing,
                topTrailingRadius: topTrailingRounded ? cornerRadii.topTrailing - innerPadding : buttonCornerRadii.topTrailing
            )
        }

        // - Regular

        else {
            return UnevenRoundedRectangle(cornerRadii: buttonCornerRadii)
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
            elements: Array(32...42),
            selection: $selection
        ) { num in
            Text("\(num)")
        }
        .luminareRoundingBehavior(top: true)

        LuminarePicker(
            elements: Array(32 ..< 36),
            selection: $selection
        ) { num in
            Text("\(num)")
        }
        .luminareRoundingBehavior(bottom: true)
    }
}
