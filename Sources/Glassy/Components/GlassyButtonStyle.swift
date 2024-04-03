//
//  GlassyButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct GlassyButtonStyle: ButtonStyle {
    let elementMinHeight: CGFloat = 40

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.quinary)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .frame(minHeight: elementMinHeight)
    }
}
