//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI

// MARK: - List

/// A stylized list.
public struct LuminareList<ContentA, ContentB, V, ID>: View
    where ContentA: View, ContentB: View, V: Hashable, ID: Hashable {
    // MARK: Environments

    @Environment(\.luminareClickedOutside) private var luminareClickedOutside
    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareCornerRadius) private var cornerRadius
    @Environment(\.luminareListContentMarginsTop) private var marginsTop
    @Environment(\.luminareListContentMarginsBottom) private var marginsBottom

    // MARK: Fields

    @Binding private var items: [V]
    @Binding private var selection: Set<V>
    private let id: KeyPath<V, ID>

    @ViewBuilder private var content: (Binding<V>) -> ContentA,
                             emptyView: () -> ContentB
    private let roundedTop: Bool, roundedBottom: Bool

    @State private var firstItem: V?
    @State private var lastItem: V?

    @State private var eventMonitor: AnyObject?

    // MARK: Initializers

    /// Initializes a ``LuminareList``.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - id: the key path for the identifiers of each element.
    ///   - roundedTop: whether to have top corners rounded.
    ///   - roundedBottom: whether to have bottom corners rounded.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        roundedTop: Bool = false, roundedBottom: Bool = false,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB
    ) {
        self._items = items
        self._selection = selection
        self.id = id
        self.content = content
        self.emptyView = emptyView
        self.roundedTop = roundedTop
        self.roundedBottom = roundedBottom
    }

    // MARK: Body

    public var body: some View {
        Group {
            if items.isEmpty {
                emptyView()
            } else {
                List(selection: $selection) {
                    if marginsTop > 0 {
                        Spacer()
                            .frame(height: marginsTop)
                    }

                    ForEach($items, id: id) { item in
                        let isDisabled = isDisabled(item.wrappedValue)
                        let tint = tint(of: item.wrappedValue)

                        Group {
                            if #available(macOS 14.0, *) {
                                LuminareListItem(
                                    items: $items,
                                    selection: $selection,
                                    item: item,
                                    firstItem: $firstItem,
                                    lastItem: $lastItem,
                                    roundedTop: roundedTop,
                                    roundedBottom: roundedBottom,
                                    content: content
                                )
                                .selectionDisabled(isDisabled)
                            } else {
                                LuminareListItem(
                                    items: $items,
                                    selection: $selection,
                                    item: item,
                                    firstItem: $firstItem,
                                    lastItem: $lastItem,
                                    roundedTop: roundedTop,
                                    roundedBottom: roundedBottom,
                                    content: content
                                )
                            }
                        }
                        .disabled(isDisabled)
                        .animation(animation, value: isDisabled)
                        .overrideTint(tint)
                    }
                    .onMove { indices, newOffset in
                        withAnimation(animation) {
                            items.move(
                                fromOffsets: indices,
                                toOffset: newOffset
                            )
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                    .padding(.horizontal, -10)
                    .transition(.slide)

                    if marginsBottom > 0 {
                        Spacer()
                            .frame(height: marginsBottom)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }

        .animation(animation, value: items)
        .animation(animation, value: selection)
        .onChange(of: luminareClickedOutside) { _ in
            withAnimation(animation) {
                selection = []
            }
        }
        .onChange(of: items) { _ in
            guard !items.isEmpty else {
                selection = []
                return
            }

            selection = selection.intersection(items)
            processSelection() // update first and last item
        }
        .onChange(of: selection) { _ in
            processSelection()

            if selection.isEmpty {
                removeEventMonitor()
            } else {
                addEventMonitor()
            }
        }
        .onAppear {
            if !selection.isEmpty {
                addEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
    }

    // MARK: Functions

    private func isDisabled(_ element: V) -> Bool {
        (element as? LuminareSelectionData)?.isSelectable == false
    }

    private func tint(of element: V) -> Color {
        (element as? LuminareSelectionData)?.tint ?? tint
    }

    private func processSelection() {
        if items.isEmpty || selection.isEmpty {
            firstItem = nil
            lastItem = nil
        } else {
            firstItem = items.first(where: { selection.contains($0) })
            lastItem = items.last(where: { selection.contains($0) })
        }
    }

    private func addEventMonitor() {
        guard eventMonitor == nil else { return }

        eventMonitor =
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                let kVK_Escape: CGKeyCode = 0x35

                if event.keyCode == kVK_Escape {
                    withAnimation(animation) {
                        selection = []
                    }
                    return nil
                }
                return event
            } as? NSObject
    }

    private func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}

// MARK: - List Item

public struct LuminareListItem<Content, V>: View
    where Content: View, V: Hashable {
    // MARK: Environments

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareCornerRadius) private var cornerRadius
    @Environment(\.luminareHasDividers) private var hasDividers
    @Environment(\.luminareListItemCornerRadius) private var itemCornerRadius
    @Environment(\.luminareListItemHeight) private var itemHeight
    @Environment(\.luminareListItemHighlightOnHover) private
    var highlightOnHover

    // MARK: Fields

    @Binding var items: [V]
    @Binding var selection: Set<V>

    @Binding var item: V
    @Binding var firstItem: V?
    @Binding var lastItem: V?

    var roundedTop: Bool
    var roundedBottom: Bool
    @ViewBuilder var content: (Binding<V>) -> Content

    @State private var isHovering = false

    private let maxLineWidth: CGFloat = 1.5
    @State private var lineWidth: CGFloat = .zero

    private let maxTintOpacity: CGFloat = 0.15
    @State private var tintOpacity: CGFloat = .zero

    // MARK: Body

    public var body: some View {
        Color.clear
            .frame(minHeight: itemHeight)
            .overlay {
                content($item)
                    .environment(\.hoveringOverLuminareItem, isHovering)
                    .foregroundStyle(isEnabled ? .primary : .secondary)
            }
            .tag(item)
            .onHover { hover in
                withAnimation(animationFast) {
                    isHovering = hover
                }
            }
            .background {
                ZStack {
                    if isEnabled {
                        itemBorder()
                        itemBackground()
                    }
                }
                .padding(.horizontal, 1)
                .padding(.leading, 1) // it's nuanced
            }
            .overlay {
                if hasDividers, !isLast {
                    VStack {
                        Spacer()

                        Divider()
                            .frame(height: 0)
                    }
                    .padding(.trailing, -1)
                }
            }

            .onChange(of: selection) { _ in
                guard isEnabled else { return }
                withAnimation(animation) {
                    updateSelection()
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(animation) {
                        // initialize selection
                        updateSelection()

                        // reset hovering state
                        isHovering = false
                    }
                }
            }
    }

    private var isFirst: Bool {
        guard !items.isEmpty else { return false }
        return item == items.first
    }

    private var isLast: Bool {
        guard !items.isEmpty else { return false }
        return item == items.last
    }

    private var isInSelection: Bool {
        guard !items.isEmpty else { return false }
        return selection.contains(item)
    }

    private var isFirstInSelection: Bool {
        guard !items.isEmpty else { return false }
        return if let firstIndex = items.firstIndex(of: item),
           firstIndex > 0 {
            !selection.contains(items[firstIndex - 1])
        } else {
            item == firstItem
        }
    }

    private var isLastInSelection: Bool {
        guard !items.isEmpty else { return false }
        return if let firstIndex = items.firstIndex(of: item),
           firstIndex < items.count - 1 {
            !selection.contains(items[firstIndex + 1])
        } else {
            item == lastItem
        }
    }

    private var itemBackgroundShape: UnevenRoundedRectangle {
        let topCornerRadius =
            if isInSelection {
                isFirstInSelection ? itemCornerRadius : 0
            } else { itemCornerRadius }
        let bottomCornerRadius =
            if isInSelection {
                isLastInSelection ? itemCornerRadius : 0
            } else { itemCornerRadius }

        return .init(
            topLeadingRadius: isFirst && roundedTop
                ? cornerRadius : topCornerRadius,
            bottomLeadingRadius: isLast && roundedBottom
                ? cornerRadius : bottomCornerRadius,
            bottomTrailingRadius: isLast && roundedBottom
                ? cornerRadius : bottomCornerRadius,
            topTrailingRadius: isFirst && roundedTop
                ? cornerRadius : topCornerRadius
        )
    }

    @ViewBuilder private func itemBackground() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.tint)
                .opacity(tintOpacity)

            if highlightOnHover, isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity(
                        (maxTintOpacity - tintOpacity) * (1 / maxTintOpacity)
                    )
            }
        }
        .clipShape(itemBackgroundShape)
    }

    @ViewBuilder private func itemBorder() -> some View {
        if isFirstInSelection, isLastInSelection {
            singleSelectionPart()
        } else if isFirstInSelection {
            firstItemPart()
        } else if isLastInSelection {
            lastItemPart()
        } else if isInSelection {
            doubleLinePart()
        }
    }

    @ViewBuilder private func firstItemPart() -> some View {
        VStack(spacing: 0) {
            // --- top half ---

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: isFirst && roundedTop
                        ? cornerRadius : itemCornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: isFirst && roundedTop
                        ? cornerRadius : itemCornerRadius
                )
                .strokeBorder(.tint, lineWidth: lineWidth)

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

            // --- bottom half ---

            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(.tint)
        }
    }

    @ViewBuilder private func lastItemPart() -> some View {
        VStack(spacing: 0) {
            // --- top half ---

            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(.tint)

            // --- bottom half ---

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: isLast && roundedBottom
                        ? cornerRadius : itemCornerRadius,
                    bottomTrailingRadius: isLast && roundedBottom
                        ? cornerRadius : itemCornerRadius,
                    topTrailingRadius: 0
                )
                .strokeBorder(.tint, lineWidth: lineWidth)

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

    @ViewBuilder private func doubleLinePart() -> some View {
        HStack {
            Rectangle()
                .frame(width: lineWidth)

            Spacer()

            Rectangle()
                .frame(width: lineWidth)
        }
        .foregroundStyle(.tint)
    }

    @ViewBuilder private func singleSelectionPart() -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: isFirst && roundedTop
                ? cornerRadius : itemCornerRadius,
            bottomLeadingRadius: isLast && roundedBottom
                ? cornerRadius : itemCornerRadius,
            bottomTrailingRadius: isLast && roundedBottom
                ? cornerRadius : itemCornerRadius,
            topTrailingRadius: isFirst && roundedTop
                ? cornerRadius : itemCornerRadius
        )
        .strokeBorder(.tint, lineWidth: lineWidth)
    }

    // MARK: Functions

    private func updateSelection() {
        guard !selection.isEmpty else {
            tintOpacity = .zero
            lineWidth = .zero
            return
        }

        tintOpacity = selection.contains(item) ? maxTintOpacity : .zero
        lineWidth = selection.contains(item) ? maxLineWidth : .zero
    }
}

// MARK: - Preview

private struct ListPreview<V>: View where V: Hashable & Comparable {
    @State var items: [V]
    @State var selection: Set<V>
    let add: (inout [V]) -> ()

    var body: some View {
        LuminareSection {
            HStack(spacing: 2) {
                Button("Add") {
                    withAnimation {
                        add(&items)
                    }
                }

                Button("Sort") {
                    withAnimation {
                        items.sort(by: <)
                    }
                }
                .disabled(items.isEmpty)

                Button("Remove", role: .destructive) {
                    items.removeAll { selection.contains($0) }
                }
                .buttonStyle(.luminareProminent)
                .disabled(selection.isEmpty)
            }
            .buttonStyle(.luminare)
            .frame(height: 34)

            LuminareList(
                items: $items,
                selection: $selection,
                id: \.self
            ) { value in
                Text("\(value.wrappedValue)")
                    .contextMenu {
                        Button("Remove") {
                            if selection.isEmpty {
                                items.removeAll { $0 == value.wrappedValue }
                            } else {
                                items.removeAll { selection.contains($0) }
                            }
                        }
                    }
                    .swipeActions {
                        Button("Swipe me!") {}
                    }
            } emptyView: {
                Text("Empty")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareList",
    traits: .sizeThatFitsLayout
) {
    ListPreview(items: [37, 42, 1, 0], selection: [42]) { items in
        guard items.count < 100 else { return }
        let random = { Int.random(in: 0 ..< 100) }
        var new = random()
        while items.contains([new]) {
            new = random()
        }
        items.append(new)
    }
    //    .luminareHasDividers(false)
    //    .luminareListContentMargins(50)
    .frame(height: 350)
}
