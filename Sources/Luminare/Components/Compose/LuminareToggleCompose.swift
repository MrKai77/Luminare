//
//  LuminareToggleCompose.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareToggleCompose<Label, Info>: View where Label: View, Info: View {
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let disabled: Bool
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let info: () -> LuminareInfoView<Info>
    
    @Binding var value: Bool

    public init(
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.disabled = disabled
        self.label = label
        self.info = info
        self._value = value
    }
    
    public init(
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == EmptyView {
        self.init(
            isOn: value,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled
        ) {
            label()
        } info: {
            LuminareInfoView()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text {
        self.init(
            isOn: value,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled
        ) {
            Text(key)
        } info: {
            info()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        disabled: Bool = false
    ) where Label == Text, Info == EmptyView {
        self.init(
            key, 
            isOn: value,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled
        ) {
            LuminareInfoView()
        }
    }

    public var body: some View {
        LuminareCompose(
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding,
            disabled: disabled
        ) {
            Toggle("", isOn: $value.animation(LuminareConstants.animation))
                .labelsHidden()
                .controlSize(.small)
                .toggleStyle(.switch)
        } label: {
            label()
        } info: {
            info()
        }
    }
}

#Preview {
    LuminareSection {
        LuminareToggleCompose("Toggle compose", isOn: .constant(true))
    }
    .padding()
}
