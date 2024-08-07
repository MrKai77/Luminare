//
//  ContentView.swift
//
//
//  Created by Kai Azim on 2024-04-01.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsWindow: LuminareSettingsWindow
    @Environment(\.tintColor) var tintColor

    let mainViewSectionOuterPadding: CGFloat = 12
    let sectionSpacing: CGFloat = 16

    @State var activeTab: SettingsTab
    @State var clickedOutsideFlag: Bool = false
    let groups: [SettingsTabGroup]
    let didTabChange: (SettingsTab) -> ()
    let togglePreview: (Bool) -> ()

    @State var scrollTimer: Timer?
    @State var scrollPosition: CGFloat = 0
    @State var isScrolling: Bool = false

    init(_ groups: [SettingsTabGroup], didTabChange: @escaping (SettingsTab) -> (), togglePreview: @escaping (Bool) -> ()) {
        self.groups = groups
        self.activeTab = groups.first!.tabs.first!
        self.didTabChange = didTabChange
        self.togglePreview = togglePreview
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                LuminareSidebarView(groups, $activeTab, didTabChange: didTabChange)
                    .frame(width: LuminareSettingsWindow.sidebarWidth)

                Divider()

                VStack(spacing: 0) {
                    TabHeaderView($activeTab)
                    Divider()

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: sectionSpacing) {
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
                            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
                                if lastPosition - scrollPosition <= 10 {
                                    stoppedScrolling()
                                }
                            }
                        }
                        .onChange(of: activeTab) { _ in
                            stoppedScrolling()
                        }
                    }
                    .clipped()
                }
                .frame(width: LuminareSettingsWindow.mainViewWidth)

                Divider()
                    .opacity(settingsWindow.showPreview ? 1 : 0)
                    .animation(LuminareSettingsWindow.fastAnimation.delay(settingsWindow.showPreview ? 0 : 0.25), value: settingsWindow.showPreview)
            }
            .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))

            Spacer(minLength: 0)
        }
        .frame(minHeight: 580)
        .buttonStyle(LuminareButtonStyle())
        .tint(tintColor())
        .ignoresSafeArea()
    }

    func stoppedScrolling() {
        isScrolling = false
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
