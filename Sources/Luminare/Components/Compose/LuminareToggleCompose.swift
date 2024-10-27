//
//  LuminareToggleCompose.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareToggleCompose<Label>: View where Label: View {
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    
    @ViewBuilder private let label: () -> Label
    
    @Binding var value: Bool

    public init(
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.label = label
        self._value = value
    }
    
    public init(
        _ key: LocalizedStringKey,
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8
    ) where Label == Text {
        self.init(
            isOn: value,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding
        ) {
            Text(key)
        }
    }

    public var body: some View {
        LuminareCompose(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding
        ) {
            Toggle("", isOn: $value.animation(LuminareConstants.animation))
                .labelsHidden()
                .controlSize(.small)
                .toggleStyle(.switch)
        } label: {
            label()
        }
    }
}

#Preview {
    LuminareSection {
        LuminareToggleCompose("Toggle compose", isOn: .constant(true))
        
        LuminareCompose("Button", alignTrailing: true) {
            Button {
                
            } label: {
                Text("Button")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
    }
    .padding()
}
