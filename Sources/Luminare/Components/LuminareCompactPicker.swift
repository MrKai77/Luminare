//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI

public struct LuminareCompactPicker<Content, V>: View
where Content: View, V: Hashable & Equatable {
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    let borderless: Bool
    
    @Binding private var selection: V
    @ViewBuilder private let content: () -> Content
    
    @State var isHovering: Bool = false
    
    public init(
        selection: Binding<V>,
        elementMinHeight: CGFloat = 30, horizontalPadding: CGFloat = 4,
        cornerRadius: CGFloat = 8,
        borderless: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.borderless = borderless
        self.content = content
    }

    public var body: some View {
        Picker("", selection: $selection) {
            content()
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .buttonStyle(.borderless)
        .padding(.trailing, -2)
        .onHover { hover in
            withAnimation(LuminareConstants.fastAnimation) {
                isHovering = hover
            }
        }
        .frame(minHeight: elementMinHeight)
        .padding(.horizontal, horizontalPadding)
        .background {
            if isHovering {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary, lineWidth: 1)
            } else if borderless {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.clear, lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary.opacity(0.7), lineWidth: 1)
            }
        }
        .background {
            if isHovering {
                Rectangle()
                    .foregroundStyle(.quinary)
            } else {
                Rectangle()
                    .foregroundStyle(.clear)
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
        .animation(LuminareConstants.fastAnimation, value: isHovering)
    }
}

#Preview {
    LuminareSection {
        LuminareCompose("Picker") {
            LuminareCompactPicker(selection: .constant(42), borderless: false) {
                ForEach(0..<200) { num in
                    Text("\(num)")
                }
            }
        }
        .padding(.trailing, -4)
        
        LuminareCompose("Button") {
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
