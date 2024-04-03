//
//  ButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct GlassyButtonStyle: ButtonStyle {

    let cornerRadius: CGFloat = 2

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.quinary)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
