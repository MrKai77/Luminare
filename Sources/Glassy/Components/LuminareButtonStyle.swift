//
//  LuminareButtonStyle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareButtonStyle: ButtonStyle {
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 40

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.quinary)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
    }
}

public struct LuminareDestructiveButtonStyle: ButtonStyle {
    let innerCornerRadius: CGFloat = 2
    let elementMinHeight: CGFloat = 40

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red.opacity(0.15))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .frame(minHeight: elementMinHeight)
            .clipShape(.rect(cornerRadius: innerCornerRadius))
    }
}
