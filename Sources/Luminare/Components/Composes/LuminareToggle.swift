//
//  LuminareToggle.swift
//  Luminare
//
//  Created by KrLite on 2024/12/17.
//

import SwiftUI

// MARK: - Toggle (Compose)

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

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        isOn value: Binding<Bool>
    ) where Label == Text {
        self.init(isOn: value) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        isOn value: Binding<Bool>
    ) where Label == Text {
        self.init(isOn: value) {
            Text(titleKey)
        }
    }

    // MARK: Body

    public var body: some View {
        LuminareCompose {
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
            Text("With an info in orange")
                .luminareToolTip(attachedTo: .topTrailing) {
                    Text("Dolore pariatur quis cupidatat irure Lorem exercitation do nulla culpa sint.")
                        .padding()
                }
                .tint(.orange)
        }
    }
}
