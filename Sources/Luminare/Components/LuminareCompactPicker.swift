//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI

struct LuminareCompactPicker<Content, V>: View
where Content: View, V: Hashable & Equatable {
    let cornerRadius: CGFloat
    
    @Binding private var selection: V
    @ViewBuilder private let content: () -> Content
    
    @State var isHovering: Bool = false
    
    public init(
        selection: Binding<V>,
        cornerRadius: CGFloat = 8,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self._selection = selection
        self.content = content
    }

    var body: some View {
        Picker(selection: $selection) {
            content()
        } label: {
            EmptyView()
        }
        .padding(.leading, 2)
        .buttonStyle(.borderless)
        .fixedSize()
        .background {
            if isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
            } else {
                Rectangle()
                    .foregroundStyle(.quinary)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius)).onHover { hover in
            withAnimation(LuminareConstants.fastAnimation) {
                isHovering = hover
            }
        }
        .animation(LuminareConstants.fastAnimation, value: isHovering)
    }
}

#Preview {
    LuminareSection {
        LuminareCompactPicker(selection: .constant(42)) {
            ForEach(0..<200) { num in
                Text("\(num)")
            }
        }
        
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
