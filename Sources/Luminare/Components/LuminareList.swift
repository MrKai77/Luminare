//
//  LuminareList.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

// MARK: - List

/// A stylized list.
public struct LuminareList<ContentA, ContentB, V, ID>: View
    where ContentA: View, ContentB: View, V: Hashable, ID: Hashable {
    // MARK: Environments

    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.luminareClickedOutside) private var luminareClickedOutside
    @Environment(\.luminareTintColor) private var tintColor
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareContentMarginsTop) private var contentMarginsTop
    @Environment(\.luminareContentMarginsLeading) private var contentMarginsLeading
    @Environment(\.luminareContentMarginsBottom) private var contentMarginsBottom
    @Environment(\.luminareContentMarginsTrailing) private var contentMarginsTrailing
    @Environment(\.luminareListItemHeight) private var itemHeight
    @Environment(\.luminareListFixedHeightUntil) private var fixedHeight

    // MARK: Fields

    @Binding private var items: [V]
    @Binding private var selection: Set<V>
    private let keyPath: KeyPath<V, ID>

    @ViewBuilder private var content: (Binding<V>) -> ContentA,
                             emptyView: () -> ContentB

    @State private var firstItem: V?
    @State private var lastItem: V?

    private let id: UUID = .init()

    // MARK: Initializers

    /// Initializes a ``LuminareList``.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - content: the content generator that accepts a value binding.
    ///   - emptyView: the view to display when nothing is inside the list.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id keyPath: KeyPath<V, ID>,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB
    ) {
        self._items = items
        self._selection = selection
        self.keyPath = keyPath
        self.content = content
        self.emptyView = emptyView
    }

    /// Initializes a ``LuminareList`` that displays literally nothing when nothing is inside the list.
    ///
    /// - Parameters:
    ///   - items: the binding of the listed items.
    ///   - selection: the binding of the set of selected items.
    ///   - content: the content generator that accepts a value binding.
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id keyPath: KeyPath<V, ID>,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
    ) where ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: keyPath,
            content: content
        ) {
            EmptyView()
        }
    }

    // MARK: Body

    public var body: some View {
        Group {
            if items.isEmpty {
                emptyView()
            } else {
                List(selection: $selection) {
                    if contentMarginsTop > 0 {
                        Spacer()
                            .frame(height: contentMarginsTop)
                    }

                    ForEach($items, id: keyPath, content: listItem)
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
                        .padding(.leading, contentMarginsLeading)
                        .padding(.trailing, contentMarginsTrailing)
                        .transition(.slide)

                    if contentMarginsBottom > 0 {
                        Spacer()
                            .frame(height: contentMarginsBottom)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDisabled(hasFixedHeight)
                .introspect(.list, on: .macOS(.v13...)) { tableView in
                    tableView.selectionHighlightStyle = .none
                }
                .luminareSectionDisableInnerPadding(true)
            }
        }
        .frame(height: hasFixedHeight ? totalHeight : nil)
        .frame(maxHeight: hasFixedHeight ? nil : fixedHeight)
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
        .luminareTint(overridingWith: appearsActive ? tintColor : .disabledControlTextColor)
    }

    private func listItem(for item: Binding<V>) -> some View {
        let isDisabled = isDisabled(item.wrappedValue)

        return LuminareListItem(
            items: $items,
            selection: $selection,
            item: item,
            firstItem: $firstItem,
            lastItem: $lastItem,
            content: content
        )
        .disabled(isDisabled)
        .animation(animation, value: isDisabled)
    }

    private var totalHeight: CGFloat {
        let margins = contentMarginsTop + contentMarginsBottom
        return CGFloat(max(1, items.count)) * itemHeight + margins
    }

    private var hasFixedHeight: Bool {
        guard let fixedHeight else { return false }
        return totalHeight <= fixedHeight
    }

    // MARK: Functions

    private func isDisabled(_ element: V) -> Bool {
        (element as? LuminareSelectionData)?.isSelectable == false
    }

    private func processSelection() {
        if items.isEmpty || selection.isEmpty {
            firstItem = nil
            lastItem = nil
        } else {
            firstItem = items.first { selection.contains($0) }
            lastItem = items.last { selection.contains($0) }
        }
    }

    private func addEventMonitor() {
        EventMonitorManager.shared.addLocalMonitor(
            for: id,
            matching: .keyDown
        ) { event in
            let kVK_Escape: CGKeyCode = 0x35

            if event.keyCode == kVK_Escape {
                withAnimation(animation) {
                    selection = []
                }
                return nil
            }
            return event
        }
    }

    private func removeEventMonitor() {
        EventMonitorManager.shared.removeMonitor(for: id)
    }
}

// MARK: - List Item

public struct LuminareListItem<Content, V>: View
    where Content: View, V: Hashable {
    // MARK: Environments

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareCornerRadii) private var cornerRadii
    @Environment(\.luminareHasDividers) private var hasDividers
    @Environment(\.luminareListItemCornerRadii) private var itemCornerRadii
    @Environment(\.luminareListItemHeight) private var itemHeight
    @Environment(\.luminareListItemHighlightOnHover) private var highlightOnHover
    @Environment(\.luminareTopLeadingRounded) private var topLeadingRounded
    @Environment(\.luminareTopTrailingRounded) private var topTrailingRounded
    @Environment(\.luminareBottomLeadingRounded) private var bottomLeadingRounded
    @Environment(\.luminareBottomTrailingRounded) private var bottomTrailingRounded

    // MARK: Fields

    @Binding var items: [V]
    @Binding var selection: Set<V>
    @Binding var item: V
    @Binding var firstItem: V?
    @Binding var lastItem: V?
    @ViewBuilder var content: (Binding<V>) -> Content

    @State private var isHovering = false

    private let maxLineWidth: CGFloat = 1.5
    @State private var lineWidth: CGFloat = .zero

    private let maxTintOpacity: CGFloat = 0.15
    @State private var tintOpacity: CGFloat = .zero

    init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        item: Binding<V>,
        firstItem: Binding<V?>,
        lastItem: Binding<V?>,
        @ViewBuilder content: @escaping (Binding<V>) -> Content
    ) {
        self._items = items
        self._selection = selection
        self._item = item
        self._firstItem = firstItem
        self._lastItem = lastItem
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        Color.clear
            .frame(minHeight: itemHeight)
            .overlay {
                content($item)
                    .environment(\.luminareItemBeingHovered, isHovering)
                    .foregroundStyle(isEnabled ? .primary : .secondary)
            }
            .tag(item)
            .background {
                if hasDividers, !isLast {
                    VStack {
                        Spacer()

                        Divider()
                    }
                    .padding(.trailing, -1)
                }

                if isEnabled {
                    ZStack {
                        itemBorder()
                        itemBackground()
                    }
                    .animation(animationFast, value: [lineWidth, tintOpacity])
                    .padding(.horizontal, 1)
                    .padding(.leading, 1) // it's nuanced
                }
            }
            .onHover { isHovering = $0 }
            .onChange(of: selection) { _ in
                guard isEnabled else { return }
                updateSelection()
            }
            .onAppear {
                DispatchQueue.main.async {
                    // Initialize selection
                    updateSelection()

                    // Reset hovering state
                    isHovering = false
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
        if let firstIndex = items.firstIndex(of: item), firstIndex > 0 {
            return !selection.contains(items[firstIndex - 1])
        } else {
            return isFirst
        }
    }

    private var isLastInSelection: Bool {
        guard !items.isEmpty else { return false }
        if let firstIndex = items.firstIndex(of: item), firstIndex < items.count - 1 {
            return !selection.contains(items[firstIndex + 1])
        } else {
            return isLast
        }
    }

    private var itemBackgroundShape: UnevenRoundedRectangle {
        let topCornerRadii =
            if isInSelection {
                isFirstInSelection ? itemCornerRadii : .zero
            } else { itemCornerRadii }
        let bottomCornerRadii =
            if isInSelection {
                isLastInSelection ? itemCornerRadii : .zero
            } else { itemCornerRadii }

        return .init(
            topLeadingRadius: isFirst && topLeadingRounded
                ? cornerRadii.topLeading : topCornerRadii.topLeading,
            bottomLeadingRadius: isLast && bottomLeadingRounded
                ? cornerRadii.bottomLeading : bottomCornerRadii.bottomLeading,
            bottomTrailingRadius: isLast && bottomTrailingRounded
                ? cornerRadii.bottomTrailing : bottomCornerRadii.bottomTrailing,
            topTrailingRadius: isFirst && topTrailingRounded
                ? cornerRadii.topTrailing : topCornerRadii.topTrailing
        )
    }

    private func itemBackground() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.tint)
                .opacity(tintOpacity)

            if highlightOnHover, isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity((maxTintOpacity - tintOpacity) * (1 / maxTintOpacity))
            }
        }
        .clipShape(itemBackgroundShape)
    }

    @ViewBuilder
    private func itemBorder() -> some View {
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

    private func firstItemPart() -> some View {
        VStack(spacing: 0) {
            // - Top half

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: isFirst && topLeadingRounded
                        ? cornerRadii.topLeading - 1
                        : itemCornerRadii.topLeading,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: isFirst && topTrailingRounded
                        ? cornerRadii.topTrailing - 1
                        : itemCornerRadii.topTrailing
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

            // - Bottom half

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

    private func lastItemPart() -> some View {
        VStack(spacing: 0) {
            // - Top half

            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(.tint)

            // - Bottom half

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: isLast && bottomLeadingRounded
                        ? cornerRadii.bottomLeading - 1
                        : itemCornerRadii.bottomLeading,
                    bottomTrailingRadius: isLast && bottomTrailingRounded
                        ? cornerRadii.bottomTrailing - 1
                        : itemCornerRadii.bottomTrailing,
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

    private func doubleLinePart() -> some View {
        HStack {
            Rectangle()
                .frame(width: lineWidth)

            Spacer()

            Rectangle()
                .frame(width: lineWidth)
        }
        .foregroundStyle(.tint)
    }

    private func singleSelectionPart() -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: isFirst && topLeadingRounded
                ? cornerRadii.topLeading - 1 : itemCornerRadii.topLeading,
            bottomLeadingRadius: isLast && bottomLeadingRounded
                ? cornerRadii.bottomLeading - 1 : itemCornerRadii.bottomLeading,
            bottomTrailingRadius: isLast && bottomTrailingRounded
                ? cornerRadii.bottomTrailing - 1 : itemCornerRadii.bottomTrailing,
            topTrailingRadius: isFirst && topTrailingRounded
                ? cornerRadii.topTrailing - 1 : itemCornerRadii.topTrailing
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
                .disabled(selection.isEmpty)
            }
            .buttonStyle(.luminare)
            .frame(height: 40)

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
    VStack {
        ListPreview(items: [37, 42, 1, 0], selection: [42]) { items in
            guard items.count < 100 else { return }
            let random = { Int.random(in: 0 ..< 100) }
            var new = random()
            while items.contains([new]) {
                new = random()
            }
            items.append(new)
        }
        .luminareListFixedHeight(until: 315)
        .luminareRoundingBehavior(bottom: true)
        .padding(20)
    }
}
