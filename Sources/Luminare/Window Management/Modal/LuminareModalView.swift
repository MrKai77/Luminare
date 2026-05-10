//
//  LuminareModalView.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-16.
//

import SwiftUI

struct LuminareModalView<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .buttonStyle(.luminare)
            .background {
                backgroundWindow()
            }
            .frame(minWidth: 12, minHeight: 12, alignment: .top)
    }

    func backgroundWindow() -> some View {
        VisualEffectView(
            material: .fullScreenUI,
            blendingMode: .behindWindow
        )
    }
}
