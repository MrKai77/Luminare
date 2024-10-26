//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI

public struct LuminareList<Header, ContentA, ContentB, Footer, V, ID>: View
where Header: View, ContentA: View, ContentB: View, Footer: View, V: Hashable, ID: Hashable {
    @Environment(\.tintColor) private var tintColor
    @Environment(\.clickedOutsideFlag) private var clickedOutsideFlag

    @Binding private var items: [V]
    @Binding private var selection: Set<V>
    private let addAction: () -> ()
    
    @ViewBuilder private let content: (Binding<V>) -> ContentA
    @ViewBuilder private let emptyView: () -> ContentB
    @ViewBuilder private let header: () -> Header
    @ViewBuilder private let footer: () -> Footer

    @State private var firstItem: V?
    @State private var lastItem: V?
    private let id: KeyPath<V, ID>

    private let addText: LocalizedStringKey
    private let removeText: LocalizedStringKey

    @State private var canRefreshSelection = true
    @State private var eventMonitor: AnyObject?

    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self._items = items
        self._selection = selection
        self.addAction = addAction
        self.id = id
        self.addText = addText
        self.removeText = removeText
        self.content = content
        self.emptyView = emptyView
        self.header = header
        self.footer = footer
    }
    
    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB
    ) where Header == Text, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: emptyView,
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
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) where ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id, 
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: {
                EmptyView()
            },
            header: header,
            footer: footer
        )
    }
    
    public init(
        _ headerKey: LocalizedStringKey,
        _ footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
    ) where Header == Text, ContentB == EmptyView, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
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
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder header: @escaping () -> Header
    ) where Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: emptyView,
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
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB
    ) where Header == Text, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: emptyView,
            header: {
                Text(headerKey)
            }
        )
    }
    
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder header: @escaping () -> Header
    ) where ContentB == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: {
                EmptyView()
            },
            header: header
        )
    }
    
    public init(
        headerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
    ) where Header == Text, ContentB == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            header: {
                Text(headerKey)
            }
        )
    }
    
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: emptyView,
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
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB
    ) where Header == EmptyView, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: emptyView,
            footer: {
                Text(footerKey)
            }
        )
    }
    
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Header == EmptyView, ContentB == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: {
                EmptyView()
            },
            footer: footer
        )
    }
    
    public init(
        footerKey: LocalizedStringKey,
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
    ) where Header == EmptyView, ContentB == EmptyView, Footer == Text {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            footer: {
                Text(footerKey)
            }
        )
    }
    
    public init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>, id: KeyPath<V, ID>,
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: emptyView,
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
        addText: LocalizedStringKey, removeText: LocalizedStringKey,
        addAction: @escaping () -> (),
        @ViewBuilder content: @escaping (Binding<V>) -> ContentA
    ) where Header == EmptyView, ContentB == EmptyView, Footer == EmptyView {
        self.init(
            items: items,
            selection: selection, id: id,
            addText: addText, removeText: removeText,
            addAction: addAction,
            content: content,
            emptyView: {
                EmptyView()
            }
        )
    }

    public var body: some View {
        LuminareSection(disablePadding: true) {
            HStack(spacing: 2) {
                Button(addText) {
                    addAction()
                }
                .buttonStyle(LuminareButtonStyle())

                Button(removeText) {
                    if !selection.isEmpty {
                        canRefreshSelection = false
                        items.removeAll(where: { selection.contains($0) })

                        selection = []

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            canRefreshSelection = true
                        }
                    }
                }
                .buttonStyle(LuminareDestructiveButtonStyle())
                .disabled(selection.isEmpty)
            }
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
                            content: content,
                            firstItem: $firstItem,
                            lastItem: $lastItem,
                            canRefreshSelection: $canRefreshSelection
                        )
                    }
                    // .onDelete(perform: deleteItems) // deleteItems crashes Loop, need to be investigated further
                    .onMove { indices, newOffset in
                        withAnimation(LuminareConstants.animation) {
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
            withAnimation(LuminareConstants.animation) {
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
        if eventMonitor != nil {
            return
        }
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let kVK_Escape: CGKeyCode = 0x35

            if event.keyCode == kVK_Escape {
                withAnimation(LuminareConstants.animation) {
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

struct LuminareListItem<Content, V>: View where Content: View, V: Hashable {
    @Environment(\.tintColor) private var tintColor

    @Binding private var item: V
    @ViewBuilder private let content: (Binding<V>) -> Content

    @Binding var items: [V]
    @Binding var selection: Set<V>

    @Binding var firstItem: V?
    @Binding var lastItem: V?
    @Binding var canRefreshSelection: Bool

    @State private var isHovering = false

    let cornerRadius: CGFloat = 2
    let maxLineWidth: CGFloat = 1.5
    @State private var lineWidth: CGFloat = .zero

    let maxTintOpacity: CGFloat = 0.15
    @State private var tintOpacity: CGFloat = .zero

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
                    .environment(\.hoveringOverLuminareItem, isHovering)
            }
            .tag(item)
            .onHover { hover in
                withAnimation(LuminareConstants.fastAnimation) {
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
            .onChange(of: selection) { _ in
                guard canRefreshSelection else { return }
                DispatchQueue.main.async {
                    withAnimation(LuminareConstants.animation) {
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

    func isFirstInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex > 0,
           !selection.contains(items[firstIndex - 1]) {
            return true
        }

        return item == firstItem
    }

    func isLastInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex < items.count - 1,
           !selection.contains(items[firstIndex + 1]) {
            return true
        }

        return item == lastItem
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
    override open func viewDidMoveToWindow() {
        super.viewWillDraw()
        selectionHighlightStyle = .none
    }
}

#Preview {
    LuminareList(
        items: .constant([37, 42, 1, 0]),
        selection: .constant([0, 42]),
        id: \.self,
        addText: .init("Add"),
        removeText: .init("Remove")
    ) {
    } content: { num in
        Text("\(num.wrappedValue)")
    } emptyView: {
        Text("Empty")
    } header: {
        Text("Header")
    } footer: {
        Text("Footer")
    }
    .padding()
}
