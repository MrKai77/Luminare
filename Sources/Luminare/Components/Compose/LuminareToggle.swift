//
//  LuminareToggle.swift
//  Luminare
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI

// MARK: - Toggle Compose

public struct LuminareToggle<Label>: View where Label: View {
    // MARK: Environments

    @Environment(\.luminareComposeControlSize) private var controlSize

    // MARK: Fields

    @Binding private var value: Bool
    @ViewBuilder private var label: () -> Label

    // MARK: Initializers

    public init(
        isOn value: Binding<Bool>,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._value = value
        self.label = label
    }

    public init(
        _ key: LocalizedStringKey,
        isOn value: Binding<Bool>
    ) where Label == Text {
        self.init(isOn: value) {
            Text(key)
        }
    }

    // MARK: Body

    public var body: some View {
        LuminareCompose(contentMaxWidth: nil) {
            Toggle("", isOn: $value)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(controlSize.proposal ?? .small)
        } label: {
            HStack(spacing: 4) {
                label()
            }
        }
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareToggle",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var value = false

    LuminareSection {
        LuminareToggle("Toggle", isOn: $value)

        LuminareToggle(isOn: $value) {
            Text("With an info")

            LuminarePopover {
                Text("Popover")
                    .padding(4)
            }
            .tint(.orange)
            .frame(maxHeight: .infinity, alignment: .top)
        }

        LuminareToggle(isOn: $value) {
            Text("With an info (simpler)")

            LuminarePopover("Popover")
                .tint(.blue)
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
