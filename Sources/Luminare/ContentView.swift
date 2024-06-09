//
//  ContentView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.tintColor) var tintColor

    let sidebarWidth: CGFloat = 260
    let mainViewWidth: CGFloat = 390
    let mainViewSectionOuterPadding: CGFloat = 12
    let previewViewWidth: CGFloat = 520
    let sectionSpacing: CGFloat = 16

    @State var activeTab: SettingsTab
    @State var clickedOutsideFlag: Bool = false
    let groups: [SettingsTabGroup]
    let didTabChange: (SettingsTab) -> Void

    @State var scrollTimer: Timer?
    @State var scrollPosition: CGFloat = 0
    @State var isScrolling: Bool = false

    init(_ groups: [SettingsTabGroup], didTabChange: @escaping (SettingsTab) -> Void) {
        self.groups = groups
        self.activeTab = groups.first!.tabs.first!
        self.didTabChange = didTabChange
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                LuminareSidebarView(groups, $activeTab, didTabChange: didTabChange)
                    .frame(width: sidebarWidth)

                Divider()

                VStack(spacing: 0) {
                    TabHeaderView($activeTab)
                    Divider()

                    ScrollView(.vertical) {
                        VStack(spacing: sectionSpacing) {
                            activeTab.view
                                .environment(\.clickedOutsideFlag, clickedOutsideFlag)
                                .environment(\.currentlyScrolling, isScrolling)
                        }
                        .padding(mainViewSectionOuterPadding)
                        .background {
                            Color.white.opacity(0.0001)
                                .padding(-12)
                                .onTapGesture {
                                    clickedOutsideFlag.toggle()
                                }
                        }
                        .background(
                             GeometryReader { inner in
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: inner.frame(in: .global).origin.y)
                             }
                        )
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            let lastPosition = scrollPosition
                            scrollPosition = value
                            isScrolling = true

                            scrollTimer?.invalidate()
                            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                                if lastPosition - scrollPosition <= 10 {
                                    isScrolling = false
                                    scrollTimer?.invalidate()
                                    scrollTimer = nil
                                }
                            }
                        }
                    }
                    .scrollIndicators(.never)
                    .clipped()
                }
                .frame(width: mainViewWidth)

                Divider()
            }
            .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))

            Spacer()
                .frame(width: previewViewWidth)
        }
        .ignoresSafeArea()

        .buttonStyle(LuminareButtonStyle())

        .tint(tintColor())
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
