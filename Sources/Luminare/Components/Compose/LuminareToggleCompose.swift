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
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let info: () -> LuminareInfoView<Info>
    
    @Binding var value: Bool

    public init(
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.label = label
        self.info = info
        self._value = value
    }
    
    public init(
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        @ViewBuilder label: @escaping () -> Label
    ) where Info == EmptyView {
        self.init(
            isOn: value,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding
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
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text {
        self.init(
            isOn: value,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding
        ) {
            Text(key)
        } info: {
            info()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        isOn value: Binding<Bool>,
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8
    ) where Label == Text, Info == EmptyView {
        self.init(
            key, 
            isOn: value,
            elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding
        ) {
            LuminareInfoView()
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
