//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI

// MARK: - List

// swiftlint:disable:next line_length
public struct LuminareList<Header, ContentA, ContentB, Actions, RemoveView, Footer, V, ID>: View where Header: View, ContentA: View, ContentB: View, Actions: View, RemoveView: View, Footer: View, V: Hashable, ID: Hashable {
    // MARK: Environments

    @Environment(\.clickedOutsideFlag) private var clickedOutsideFlag
    @Environment(\.luminareAnimation) private var animation

    // MARK: Fields

    @Binding private var items: [V]
    @Binding private var selection: Set<V>
    private let id: KeyPath<V, ID>
    private let actionsMaxHeight: CGFloat?

    @ViewBuilder private let content: (Binding<V>) -> ContentA, emptyView: () -> ContentB
    @ViewBuilder private let actions: () -> Actions, removeView: () -> RemoveView
    @ViewBuilder private let header: () -> Header, footer: () -> Footer

    @State private var firstItem: V?
    @State private var lastItem: V?

    @State private var canRefreshSelection = true
    @State private var eventMonitor: AnyObject?

    // MARK: Initializers

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self._items = items
        self._selection = selection
        self.id = id
        self.actionsMaxHeight = actionsMaxHeight
        self.content = content
        self.emptyView = emptyView
        self.actions = actions
        self.removeView = removeView
        self.header = header
        self.footer = footer
    }

    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) where ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: removeView,
            header: header,
            footer: footer
        )
    }

    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, ContentB == EmptyView, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header
    ) where Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: removeView,
            header: header,
            footer: {
                EmptyView()
            }
        )
    }

    public init(
        headerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, RemoveView == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            }
        )
    }

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder header: @escaping () -> Header
    ) where ContentB == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: removeView,
            header: header
        )
    }

    public init(
        headerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == Text, ContentB == EmptyView, RemoveView == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            header: {
                Text(headerKey)
            }
        )
    }

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: removeView,
            header: {
                EmptyView()
            },
            footer: footer
        )
    }

    public init(
        footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView, ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: removeView,
            footer: footer
        )
    }

    public init(
        footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, ContentB == EmptyView, RemoveView == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            actions: actions,
            removeView: {
                Text(removeKey)
            },
            footer: {
                Text(footerKey)
            }
        )
    }

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder removeView: @escaping () -> RemoveView
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: emptyView,
            actions: actions,
            removeView: removeView,
            header: {
                EmptyView()
            },
            footer: {
                EmptyView()
            }
        )
    }

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        actionsMaxHeight: CGFloat? = 40,
        removeKey: LocalizedStringKey,
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView, ContentB == EmptyView, RemoveView == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            actionsMaxHeight: actionsMaxHeight,
            content: content,
            emptyView: {
                EmptyView()
            },
            actions: actions,
            removeView: {
                Text(removeKey)
            }
        )
    }

    // MARK: Body

    public var body: some View {
        LuminareSection(hasPadding: false) {
            HStack(spacing: 2) {
                actions()
                    .buttonStyle(LuminareButtonStyle())

                Button {
                    if !selection.isEmpty {
                        canRefreshSelection = false
                        items.removeAll(where: { selection.contains($0) })

                        selection = []

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            canRefreshSelection = true
                        }
                    }
                } label: {
                    removeView()
                }
                .buttonStyle(LuminareDestructiveButtonStyle())
                .disabled(selection.isEmpty)
            }
            .frame(maxHeight: actionsMaxHeight)
            .modifier(
                LuminareCroppedSectionItem(
                    isFirstChild: true,
                    isLastChild: false
                )
            )
            .padding(.vertical, 4)
            .padding(.bottom, 4)
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
                            firstItem: $firstItem,
                            lastItem: $lastItem,
                            canRefreshSelection: $canRefreshSelection,
                            content: content
                        )
                    }
                    // TODO: `deleteItems` crashes Loop, need to be investigated further
                    // .onDelete(perform: deleteItems)
                    .onMove { indices, newOffset in
                        withAnimation(animation) {
                            items.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, -10)
                }
                .frame(height: CGFloat(items.count * 50))
                .padding(.top, 4)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .listStyle(.plain)
            }
        } header: {
            header()
        } footer: {
            footer()
        }
        .onChange(of: clickedOutsideFlag) { _ in
            withAnimation(animation) {
                selection = []
            }
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

    // TODO: investigate this
    // #warning("onDelete & deleteItems WILL crash on macOS 14.5, but it's fine on 14.4 and below.")
    // private func deleteItems(at offsets: IndexSet) {
    //  withAnimation {
    //    items.remove(atOffsets: offsets)
    //  }
    // }

    func processSelection() {
        if selection.isEmpty {
            firstItem = nil
            lastItem = nil
        } else {
            firstItem = items.first(where: { selection.contains($0) })
            lastItem = items.last(where: { selection.contains($0) })
        }
    }

    func addEventMonitor() {
        guard eventMonitor == nil else { return }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let kVK_Escape: CGKeyCode = 0x35 // swiftlint:disable:this identifier_name

            if event.keyCode == kVK_Escape {
                withAnimation(animation) {
                    selection = []
                }
                return nil
            }
            return event
        } as? NSObject
    }

    func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}

// MARK: - List Item

public struct LuminareListItem<Content, V>: View where Content: View, V: Hashable {
    // MARK: Environments

    @Environment(\.luminareTint) private var tint
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    // MARK: Fields

    @Binding private var item: V
    @ViewBuilder private let content: (Binding<V>) -> Content

    @Binding private var items: [V]
    @Binding private var selection: Set<V>

    @Binding private var firstItem: V?
    @Binding private var lastItem: V?
    @Binding private var canRefreshSelection: Bool

    @State private var isHovering = false

    private let cornerRadius: CGFloat = 2
    private let maxLineWidth: CGFloat = 1.5
    @State private var lineWidth: CGFloat = .zero

    private let maxTintOpacity: CGFloat = 0.15
    @State private var tintOpacity: CGFloat = .zero

    // MARK: Initializers

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        item: Binding<V>,
        firstItem: Binding<V?>,
        lastItem: Binding<V?>,
        canRefreshSelection: Binding<Bool>,
        @ViewBuilder content: @escaping (Binding<V>) -> Content
    ) {
        self._items = items
        self._selection = selection
        self._item = item
        self._firstItem = firstItem
        self._lastItem = lastItem
        self._canRefreshSelection = canRefreshSelection
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        Color.clear
            .frame(height: 50)
            .overlay {
                content($item)
                    .environment(\.hoveringOverLuminareItem, isHovering)
            }
            .tag(item)
            .onHover { hover in
                withAnimation(animationFast) {
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
                if item != items.last {
                    VStack {
                        Spacer()
                        Divider()
                    }
                    .padding(.trailing, -0.5)
                }
            }
            .onChange(of: selection) { newSelection in
                guard canRefreshSelection else { return }
                DispatchQueue.main.async {
                    withAnimation(animation) {
                        updateSelection(selection: newSelection)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(animation) {
                        // initialize selection
                        updateSelection(selection: selection)
                    }
                }
            }
    }

    @ViewBuilder func getItemBackground() -> some View {
        Group {
            tint()
                .opacity(tintOpacity)

            if isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity((maxTintOpacity - tintOpacity) * (1 / maxTintOpacity))
            }
        }
    }

    @ViewBuilder func getItemBorder() -> some View {
        if isFirstInSelection(), isLastInSelection() {
            singleSelectionPart(isBottomOfList: item == items.last)

        } else if isFirstInSelection() {
            firstItemPart()

        } else if isLastInSelection() {
            lastItemPart(isBottomOfList: item == items.last)

        } else if selection.contains(item) {
            doubleLinePart()
        }
    }

    @ViewBuilder private func firstItemPart() -> some View {
        VStack(spacing: 0) {
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: cornerRadius
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

            // --- bottom part ---

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

    @ViewBuilder private func lastItemPart(isBottomOfList: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Rectangle()
                    .frame(width: lineWidth)

                Spacer()

                Rectangle()
                    .frame(width: lineWidth)
            }
            .foregroundStyle(.tint)

            // --- bottom part ---

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
                    bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
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

    @ViewBuilder private func singleSelectionPart(isBottomOfList: Bool) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            bottomTrailingRadius: isBottomOfList ? (12 + lineWidth / 2.0) : cornerRadius,
            topTrailingRadius: cornerRadius
        )
        .strokeBorder(.tint, lineWidth: lineWidth)
    }

    // MARK: Functions

    private func updateSelection(selection: Set<V>) {
        tintOpacity = selection.contains(item) ? maxTintOpacity : .zero
        lineWidth = selection.contains(item) ? maxLineWidth : .zero
    }

    private func isFirstInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex > 0,
           !selection.contains(items[firstIndex - 1]) {
            return true
        }

        return item == firstItem
    }

    private func isLastInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex < items.count - 1,
           !selection.contains(items[firstIndex + 1]) {
            return true
        }

        return item == lastItem
    }
}

// MARK: - Preview

private struct ListPreview<V>: View where V: Hashable & Comparable {
    @State var items: [V]
    @State var selection: Set<V>
    let add: (inout [V]) -> Void

    var body: some View {
        LuminareList(
            "List Header", "List Footer",
            items: $items,
            selection: $selection,
            id: \.self,
            removeKey: .init("Remove")
        ) { value in
            Text("\(value.wrappedValue)")
                .contextMenu {
                    Button("Remove") {
                        withAnimation {
                            items.removeAll { selection.contains($0) || value.wrappedValue == $0 }
                        }
                    }
                }
        } emptyView: {
            Text("Empty")
                .foregroundStyle(.secondary)
        } actions: {
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
        }
    }
}

#Preview("LuminareList") {
    ListPreview(items: [37, 42, 1, 0], selection: [42]) { items in
        guard items.count < 100 else { return }
        let random = { Int.random(in: 0..<100) }
        var new = random()
        while items.contains([new]) { new = random() }
        items.append(new)
    }
    .padding()
}
