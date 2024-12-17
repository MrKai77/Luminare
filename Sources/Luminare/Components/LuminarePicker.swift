//
//  LuminarePicker.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-05.
//

import SwiftUI

public enum LuminarePickerRoundedCornerBehavior: String, Hashable, Equatable, Identifiable, CaseIterable, Codable, Sendable {
    case never
    case always

    public var id: Self { self }

    public var negate: Self {
        switch self {
        case .never:
            .always
        case .always:
            .never
        }
    }

    var isRounded: Bool {
        switch self {
        case .never:
            false
        case .always:
            true
        }
    }
}

// MARK: - Picker

/// A stylized, grid based picker.
public struct LuminarePicker<Content, V>: View where Content: View, V: Equatable {
    // MARK: Environments

    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareButtonCornerRadii) private var buttonCornerRadii
    @Environment(\.luminarePickerRoundedTopCornerBehavior) private var topCorner
    @Environment(\.luminarePickerRoundedBottomCornerBehavior) private var bottomCorner

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
        let roundedTop = topCorner.isRounded, roundedBottom = bottomCorner.isRounded

        // - Top leading

        if column == 0, row == 0, roundedTop {
            return UnevenRoundedRectangle(
                topLeadingRadius: cornerRadii.topLeading - innerPadding,
                bottomLeadingRadius:
                (isVerticallyCompact && roundedBottom) ? cornerRadii.bottomLeading - innerPadding : buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: buttonCornerRadii.bottomTrailing,
                topTrailingRadius:
                isHorizontallyCompact ? cornerRadii.topTrailing - innerPadding : buttonCornerRadii.topTrailing
            )
        }

        // - Bottom leading

        else if column == 0, row == maxRowIndex, roundedBottom {
            return UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: cornerRadii.bottomLeading - innerPadding,
                bottomTrailingRadius:
                isHorizontallyCompact ? cornerRadii.bottomTrailing - innerPadding : buttonCornerRadii.bottomTrailing,
                topTrailingRadius: buttonCornerRadii.topTrailing
            )
        }

        // - Bottom trailing

        else if column == maxColumnIndex, row == maxRowIndex, roundedBottom {
            return UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: buttonCornerRadii.bottomLeading,
                bottomTrailingRadius: cornerRadii.bottomTrailing - innerPadding,
                topTrailingRadius: buttonCornerRadii.topTrailing
            )
        }

        // - Top trailing

        else if column == maxColumnIndex, row == 0, roundedTop {
            return UnevenRoundedRectangle(
                topLeadingRadius: buttonCornerRadii.topLeading,
                bottomLeadingRadius: buttonCornerRadii.bottomLeading,
                bottomTrailingRadius:
                (isHorizontallyCompact && roundedBottom) ? cornerRadii.bottomTrailing - innerPadding : buttonCornerRadii.bottomTrailing,
                topTrailingRadius: cornerRadii.topTrailing - innerPadding
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
            elements: Array(32 ..< 50),
            selection: $selection
        ) { num in
            Text("\(num)")
        }
        .luminarePickerRoundedCorner(.always)
    }
}
