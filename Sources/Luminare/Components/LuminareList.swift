//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI

public struct LuminareList<Content, V>: View where Content: View, V: Hashable, V: Identifiable {
    @Environment(\.tintColor) var tintColor

    let header: String?
    @Binding var items: [V]
    @Binding var selection: Set<V>
    let addAction: () -> Void
    let content: (Binding<V>) -> Content

    @State private var firstItem: V?
    @State private var lastItem: V?

    let cornerRadius: CGFloat = 2
    let lineWidth: CGFloat = 1.5

    public init(
        _ header: String? = nil,
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        addAction: @escaping () -> Void,
        @ViewBuilder content: @escaping (Binding<V>) -> Content
    ) {
        self.header = header
        self._items = items
        self._selection = selection
        self.addAction = addAction
        self.content = content
    }

    public var body: some View {
        LuminareSection(header, disablePadding: true) {
            HStack(spacing: 2) {
                Button("Add") {
                    withAnimation(.smooth(duration: 0.25)) {
                        addAction()
                    }
                }

                Button("Remove") {
                    if !self.selection.isEmpty {
                        withAnimation(.smooth(duration: 0.25)) {
                            self.items.removeAll(where: { selection.contains($0) })
                        }

                        self.selection = []
                    }
                }
                .buttonStyle(LuminareDestructiveButtonStyle())
                .disabled(self.selection.isEmpty)
            }
            .modifier(
                // Needed since disablePadding is disabled
                LuminareCroppedSectionItem(
                    isFirstChild: true,
                    isLastChild: false
                )
            )
            .padding(.bottom, 4)

            List(selection: $selection) {
                ForEach($items) { item in
                    LuminareListItem(
                        items: $items,
                        selection: $selection,
                        item: item,
                        content: content,
                        firstItem: $firstItem,
                        lastItem: $lastItem
                    )
                }
                .onMove { indices, newOffset in
                    items.move(fromOffsets: indices, toOffset: newOffset)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .frame(height: CGFloat(self.items.count * 50))
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .listStyle(.plain)
            .padding(.horizontal, -10)
            .padding(.vertical, -4)
            .padding(.top, 2)

            // For selection outlines
            .padding(.horizontal, 1) // TODO: FIND OUT WHY THIS THING IS 1 PT OFF
            .padding(self.lineWidth / 2.0)

            .onChange(of: self.selection) { _ in
                self.processSelection()
            }
        }
    }

    func processSelection() {
        if selection.isEmpty {
            self.firstItem = nil
            self.lastItem = nil
        } else {
            self.firstItem = self.items.first(where: { selection.contains($0) })
            self.lastItem = self.items.last(where: { selection.contains($0) })
        }
    }
}

public struct HoveringOverLuminareListItem: EnvironmentKey {
    public static var defaultValue: Bool = false
}

public extension EnvironmentValues {
    var hoveringOverLuminareListItem: Bool {
        get { return self[HoveringOverLuminareListItem.self] }
        set { self[HoveringOverLuminareListItem.self] = newValue }
    }
}

struct LuminareListItem<Content, V>: View where Content: View, V: Hashable, V: Identifiable {
    @Environment(\.tintColor) var tintColor

    @Binding var item: V
    let content: (Binding<V>) -> Content

    @Binding var items: [V]
    @Binding var selection: Set<V>

    @Binding var firstItem: V?
    @Binding var lastItem: V?

    @State var isHovering: Bool = false

    let cornerRadius: CGFloat = 2
    let maxLineWidth: CGFloat = 1.5
    @State var lineWidth: CGFloat = .zero

    let maxTintOpacity: CGFloat = 0.15
    @State var tintOpacity: CGFloat = .zero

    init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        item: Binding<V>,
        @ViewBuilder content: @escaping (Binding<V>) -> Content,
        firstItem: Binding<V?>,
        lastItem: Binding<V?>
    ) {
        self._items = items
        self._selection = selection
        self._item = item
        self.content = content
        self._firstItem = firstItem
        self._lastItem = lastItem
    }

    var body: some View {
        Color.clear
            .frame(height: 50)
            .overlay {
                content($item)
                    .environment(\.hoveringOverLuminareListItem, isHovering)
            }
            .tag(item)

            .background {
                ZStack {
                    getItemBorder()
                    getItemBackground()
                }
            }

            .overlay {
                if item != self.items.last {
                    VStack {
                        Spacer()
                        Divider()
                    }
                    .padding(.trailing, -0.5)
                }
            }

            .onHover { hover in
                withAnimation(.easeOut(duration: 0.1)) {
                    isHovering = hover
                }
            }

            .onChange(of: self.selection) { _ in
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.2)) {
                        tintOpacity = self.selection.contains(item) ? maxTintOpacity : .zero
                        lineWidth = self.selection.contains(item) ? maxLineWidth : .zero
                    }
                }
            }
    }

    @ViewBuilder func getItemBackground() -> some View {
        Group {
            tintColor
                .opacity(tintOpacity)

            if self.isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity((maxTintOpacity - tintOpacity) * (1 / maxTintOpacity))
            }
        }
        .mask {
            if item == self.items.last {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: (12 + lineWidth / 2.0),
                    bottomTrailingRadius: (12 + lineWidth / 2.0),
                    topTrailingRadius: 0
                )
                .foregroundColor(.black)
            } else {
                Rectangle()
                    .foregroundColor(.black)
            }
        }
    }

    @ViewBuilder func getItemBorder() -> some View {
        if self.isFirstInSelection() && self.isLastInSelection() {
            self.singleSelectionPart(isBottomOfList: item == self.items.last)

        } else if self.isFirstInSelection() {
            self.firstItemPart()

        } else if self.isLastInSelection() {
            self.lastItemPart(isBottomOfList: item == self.items.last)

        } else if self.selection.contains(item) {
            self.doubleLinePart()
        }
    }

    func isFirstInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex > 0,
           !self.selection.contains(self.items[firstIndex - 1]) {
            return true
        }

        return item == self.firstItem
    }

    func isLastInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex < self.items.count - 1,
           !self.selection.contains(self.items[firstIndex + 1]) {
            return true
        }

        return item == self.lastItem
    }

    func firstItemPart() -> some View {
        VStack(spacing: 0) {
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: cornerRadius
                )
                .strokeBorder(tintColor, lineWidth: lineWidth)

                VStack {
                    Color.clear
                    HStack {
                        Spacer()
                            .frame(width: lineWidth)

                        Rectangle()
                            .foregroundStyle(.white)
                            .blendMode(.destinationOut)

                        Spacer()
                            .frame(width: lineWidth)
                    }
                }
            }
            .compositingGroup()

            // --- Bottom part ---

            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(tintColor)
        }
    }

    func lastItemPart(isBottomOfList: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(tintColor)

            // --- Bottom part ---

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    topTrailingRadius: 0
                )
                .strokeBorder(tintColor, lineWidth: lineWidth)

                VStack {
                    HStack {
                        Spacer()
                            .frame(width: lineWidth)

                        Rectangle()
                            .foregroundStyle(.white)
                            .blendMode(.destinationOut)

                        Spacer()
                            .frame(width: lineWidth)
                    }
                    Color.clear
                }
            }
            .compositingGroup()
        }
    }

    func doubleLinePart() -> some View {
        HStack {
            Rectangle()
                .frame(width: lineWidth)

            Spacer()

            Rectangle()
                .frame(width: lineWidth)
        }
        .foregroundStyle(tintColor)
    }

    func singleSelectionPart(isBottomOfList: Bool) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            topTrailingRadius: cornerRadius
        )
        .strokeBorder(tintColor, lineWidth: lineWidth)
    }
}

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewWillDraw()
        selectionHighlightStyle = .none
        draggingDestinationFeedbackStyle = .gap
    }
}
