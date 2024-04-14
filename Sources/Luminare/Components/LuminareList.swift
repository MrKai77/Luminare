//
//  LuminareList.swift
//
//
//  Created by Kai Azim on 2024-04-13.
//

import SwiftUI
import SwiftUIIntrospect

public struct LuminareList<Content, V>: View where Content: View, V: Hashable, V: Identifiable {
    @Environment(\.tintColor) var tintColor

    let header: String?
    @Binding var items: [V]
    @Binding var selection: Set<V>
    let addAction: () -> Void
    let content: (V) -> Content

    @State private var firstItem: V?
    @State private var lastItem: V?

    let cornerRadius: CGFloat = 2
    let lineWidth: CGFloat = 1.5

    public init(_ header: String? = nil, items: Binding<[V]>, selection: Binding<Set<V>>, addAction: @escaping () -> Void, content: @escaping (V) -> Content) {
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
                LuminareCroppedSectionItem(
                    isFirstChild: true,
                    isLastChild: false
                )
            )
            .padding(.bottom, 4)

            List(selection: $selection) {
                ForEach(items) { item in
                    Color.clear
                        .frame(height: 50)
                        .overlay {
                            content(item)
                        }
                        .tag(item)

                        .background {
                            ZStack {
                                getItemSelectionBorder(item: item)
                                getItemSelectionBackground(item: item)
                            }
                        }

                        .overlay {
                            if item != self.items.last {
                                VStack {
                                    Spacer()
                                    Divider()
                                }
                                .padding(.leading, 1)
                                .padding(.trailing, 0.5)
                            }
                        }
                }
                .onMove { indices, newOffset in
                    items.move(fromOffsets: indices, toOffset: newOffset)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .frame(height: CGFloat(self.items.count * 50))
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .listStyle(.plain)
            .introspect(.list, on: .macOS(.v12, .v13, .v14)) { tableView in
                tableView.selectionHighlightStyle = .none
            }
            .padding(.horizontal, -10)
            .padding(.vertical, -5)
            .onChange(of: self.selection) { _ in
                if selection.isEmpty {
                    self.firstItem = nil
                    self.lastItem = nil
                } else {
                    self.firstItem = self.items.first(where: { selection.contains($0) })
                    self.lastItem = self.items.last(where: { selection.contains($0) })
                }
            }
            .padding(.top, 2)

            // For selection outlines
            .padding(.horizontal, 1) // TODO: FIND OUT WHY THIS THING IS 1 PT OFF
            .padding(0.75)
            .padding(.vertical, 0.5)
        }
    }

    @ViewBuilder func getItemSelectionBackground(item: V) -> some View {
        tintColor.opacity(self.selection.contains(item) ? 0.15 : 0)
            .mask {
                 if item == self.lastItem && item == self.items.last {
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

    @ViewBuilder func getItemSelectionBorder(item: V) -> some View {
        if item == self.firstItem && self.firstItem == self.lastItem {
            self.singleSelectionPart(isBottomOfList: item == self.items.last)
        } else if item == self.firstItem {
            self.topSelectionPart()
        } else if item == self.lastItem {
            self.lastItemPart(isBottomOfList: item == self.items.last)
        } else if self.selection.contains(item) {
            self.doubleLinePart()
        }
    }

    func topSelectionPart() -> some View {
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
