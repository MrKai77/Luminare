//
//  LuminareWindowMeasuredContentView.swift
//  Luminare
//
//  Created by Kai Azim on 2026-05-10.
//

import SwiftUI

struct LuminareWindowMeasuredContentView<Content>: View where Content: View {
    @ViewBuilder let content: () -> Content
    let setWindowSize: (CGSize) -> ()

    var body: some View {
        ZStack(alignment: .topLeading) {
            LuminareView(content: content)
                .fixedSize()
                .onGeometryChange(for: CGSize.self, of: \.size, action: setWindowSize)
                .frame(minWidth: 12, minHeight: 12, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
