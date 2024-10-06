//
//  LuminareSidebar.swift
//  Luminare
//
//  Created by Kai Azim on 2024-09-29.
//

import SwiftUI

public struct LuminareSidebar<Content>: View where Content: View {
    let content: () -> Content
    let width: CGFloat

    public init(@ViewBuilder content: @escaping () -> Content, width: CGFloat = 260) {
        self.content = content
        self.width = width
    }

    public var body: some View {
        VStack(spacing: 24) {
            content()
        }
        .padding(.horizontal, 12)
        .frame(width: width)
        .frame(minHeight: 580, maxHeight: .infinity, alignment: .top)
        .luminareBackground()
    }
}
