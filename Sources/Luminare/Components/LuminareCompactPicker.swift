//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI

struct LuminareCompactPicker<Label, Content, Info, V>: View
where Label: View, Content: View, Info: View, V: Hashable & Equatable {
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let disabled: Bool = false
    
    @Binding private var selection: V
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let info: () -> LuminareInfoView<Info>
    
    public init(
        elementMinHeight: CGFloat = 34, horizontalPadding: CGFloat = 8,
        selection: Binding<V>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self._selection = selection
        self.content = content
        self.label = label
        self.info = info
    }

    var body: some View {
        LuminareLabeledContent(elementMinHeight: elementMinHeight, horizontalPadding: horizontalPadding) {
            Picker("", selection: $selection) {
                content()
            }
            .buttonStyle(.borderless)
            .padding(.leading, -4)
            .clipShape(Capsule())
            .fixedSize()
            .padding(4)
            .background {
                ZStack {
                    Capsule()
                        .strokeBorder(.quaternary, lineWidth: 1)
                    
                    Capsule()
                        .foregroundStyle(.quinary.opacity(0.5))
                }
            }
            .disabled(disabled)
        } label: {
            label()
        } info: {
            info()
        }
    }
}

#Preview {
    LuminareSection {
        LuminareCompactPicker(selection: .constant(42)) {
            ForEach(0..<200) { num in
                Text("\(num)")
            }
        } label: {
            Text("Picker")
        } info: {
            LuminareInfoView()
        }
    }
    .padding()
}
