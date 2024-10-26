//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI

struct LuminareCompactPicker<Content, V>: View
where Content: View, V: Hashable & Equatable {
    @Binding private var selection: V
    @ViewBuilder private let content: () -> Content
    
    public init(
        selection: Binding<V>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.content = content
    }

    var body: some View {
        Picker(selection: $selection) {
            content()
        } label: {
            EmptyView()
        }
        .padding(.trailing, -2)
        .buttonStyle(.borderless)
    }
}

#Preview {
    LuminareSection {
        LuminareLabeledContent("Picker") {
            Picker(selection: .constant(42)) {
                ForEach(0..<200) { num in
                    Text("\(num)")
                }
            } label: {
                EmptyView()
            }
            .frame(height: 30)
            .padding(.horizontal, 8)
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
        .padding(.trailing, -4)
        
        LuminareLabeledContent("Button") {
            Button {
                
            } label: {
                Text("Test")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
        .padding(.trailing, -4)
    }
    .padding()
}
