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
    let horizontalPadding: CGFloat = 8

    let title: LocalizedStringKey
    @Binding var value: Bool

    public init(_ title: LocalizedStringKey, isOn value: Binding<Bool>) {
        self.title = title
        self._value = value
    }

    public var body: some View {
        HStack {
            Text(title)
            Spacer()

            Toggle("", isOn: $value.animation(.smooth(duration: 0.3)))
                .labelsHidden()
                .controlSize(.small)
                .toggleStyle(.switch)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(minHeight: elementMinHeight)
    }
}
