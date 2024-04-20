//
//  LuminareToggle.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareToggle: View {
    @Environment(\.tintColor) var tintColor

    let elementMinHeight: CGFloat = 34
    let horizontalPadding: CGFloat = 12

    let title: String
    @Binding var value: Bool

    public init(_ title: String, isOn value: Binding<Bool>) {
        self.title = title
        self._value = value
    }
    public var body: some View {
        HStack {
            Text(title)
            Spacer()

            Toggle("", isOn: $value)
                .labelsHidden()
                .controlSize(.small)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(minHeight: elementMinHeight)
    }
}
