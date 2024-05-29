//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI

public struct LuminareList<ContentA, ContentB, V, ID>: View where ContentA: View, ContentB: View, V: Hashable, ID: Hashable {
    @Environment(\.tintColor) var tintColor

    let header: LocalizedStringKey?
    @Binding var items: [V]
    @Binding var selection: Set<V>
    let addAction: () -> Void
    let content: (Binding<V>) -> ContentA
    let emptyView: () -> ContentB

    @State private var firstItem: V?
    @State private var lastItem: V?
    let id: KeyPath<V, ID>

    @State var canRefreshSelection: Bool = true
    let cornerRadius: CGFloat = 2
    let lineWidth: CGFloat = 1.5

    public init(
        _ header: LocalizedStringKey? = nil,
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        addAction: @escaping () -> Void,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        id: KeyPath<V, ID>
    ) {
        self.header = header
        self._items = items
        self._selection = selection
        self.addAction = addAction
        self.content = content
        self.emptyView = emptyView
        self.id = id
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
                        canRefreshSelection = false
                        withAnimation(.smooth(duration: 0.25)) {
                            self.items.removeAll(where: { selection.contains($0) })
                        }

                        self.selection = []

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.canRefreshSelection = true
                        }
                    }
                }
                .buttonStyle(LuminareDestructiveButtonStyle())
                .disabled(self.selection.isEmpty)
            }
            .modifier(
                LuminareCroppedSectionItem(
                    isFirstChild: true,
                    isLastChild: false
                )
            )
            .padding(.bottom, 8)
            .padding([.top, .horizontal], 1)

            if items.isEmpty {
                emptyView()
                    .frame(minHeight: 50)
            } else {
                List(selection: $selection) {
                    ForEach($items, id: id) { item in
                        LuminareListItem(
                            items: $items,
                            selection: $selection,
                            item: item,
                            content: content,
                            firstItem: $firstItem,
                            lastItem: $lastItem,
                            canRefreshSelection: $canRefreshSelection
                        )
                    }
                    // .onDelete(perform: deleteItems) // deleteItems crashes Loop, need to be investigated further
                    .onMove { indices, newOffset in
                        withAnimation(.smooth(duration: 0.25)) {
                            items.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, -10)
                }
                .frame(height: CGFloat(self.items.count * 50))
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .listStyle(.plain)
                .onChange(of: self.selection) { _ in
                    self.processSelection()
                }
            }
        }
    }

    // #warning("onDelete & deleteItems WILL crash on macOS 14.5, but it's fine on 14.4 and below.")
    // private func deleteItems(at offsets: IndexSet) {
    //  withAnimation {
    //    items.remove(atOffsets: offsets)
    //  }
    //}

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

extension EnvironmentValues {
    public var hoveringOverLuminareListItem: Bool {
        get { return self[HoveringOverLuminareListItem.self] }
        set { self[HoveringOverLuminareListItem.self] = newValue }
    }
}

struct LuminareListItem<Content, V>: View where Content: View, V: Hashable {
    @Environment(\.tintColor) var tintColor

    @Binding var item: V
    let content: (Binding<V>) -> Content

    @Binding var items: [V]
    @Binding var selection: Set<V>

    @Binding var firstItem: V?
    @Binding var lastItem: V?
    @Binding var canRefreshSelection: Bool

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
        lastItem: Binding<V?>,
        canRefreshSelection: Binding<Bool>
    ) {
        self._items = items
        self._selection = selection
        self._item = item
        self.content = content
        self._firstItem = firstItem
        self._lastItem = lastItem
        self._canRefreshSelection = canRefreshSelection
    }

    var body: some View {
        Color.clear
            .frame(height: 50)
            .overlay {
                content($item)
                    .environment(\.hoveringOverLuminareListItem, isHovering)
            }
            .tag(item)

            .onHover { hover in
                withAnimation(.easeOut(duration: 0.1)) {
                    isHovering = hover
                }
            }

            .background {
                ZStack {
                    getItemBorder()
                    getItemBackground()
                }
                .padding(.horizontal, 1)
                .padding(.leading, 1)
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
            .onChange(of: self.selection) { _ in
                guard canRefreshSelection else { return }
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.2)) {
                        tintOpacity = selection.contains(item) ? maxTintOpacity : .zero
                        lineWidth = selection.contains(item) ? maxLineWidth : .zero
                    }
                }
            }
    }

    @ViewBuilder func getItemBackground() -> some View {
        Group {
            tintColor()
                .opacity(tintOpacity)

            if self.isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity((maxTintOpacity - tintOpacity) * (1 / maxTintOpacity))
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
                .strokeBorder(tintColor(), lineWidth: lineWidth)

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
            .foregroundStyle(tintColor())
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
            .foregroundStyle(tintColor())

            // --- Bottom part ---

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    topTrailingRadius: 0
                )
                .strokeBorder(tintColor(), lineWidth: lineWidth)

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
        .foregroundStyle(tintColor())
    }

    func singleSelectionPart(isBottomOfList: Bool) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            topTrailingRadius: cornerRadius
        )
        .strokeBorder(tintColor(), lineWidth: lineWidth)
    }
}

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewWillDraw()
        selectionHighlightStyle = .none
    }
}
