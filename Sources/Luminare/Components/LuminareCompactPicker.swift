//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI

public struct LuminareCompactPicker<Content, V>: View
where Content: View, V: Hashable & Equatable {
    public enum PickerStyle {
        case menu
        case segmented
        
        var style: any SwiftUI.PickerStyle {
            switch self {
            case .menu: .menu
            case .segmented: .segmented
            }
        }
    }
    
    let elementMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    let borderless: Bool
    let style: PickerStyle
    
    @Binding private var selection: V
    @ViewBuilder private let content: () -> Content
    
    @State var isHovering: Bool = false
    
    public init(
        selection: Binding<V>,
        elementMinHeight: CGFloat = 30, horizontalPadding: CGFloat = 4,
        cornerRadius: CGFloat = 8,
        borderless: Bool = true,
        style: PickerStyle = .menu,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.borderless = borderless
        self.style = style
        self.content = content
    }

    public var body: some View {
        Group {
            switch style {
            case .menu:
                _VariadicView.Tree(MenuLayout(selection: $selection), content: content)
            case .segmented:
                _VariadicView.Tree(SegmentedLayout(selection: $selection, isHovering: $isHovering), content: content)
            }
        }
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
    
    @ViewBuilder private func variadic<Layout>(
        layout: Layout, content: () -> some View
    ) -> some View where Layout: _VariadicView.ViewRoot {
        _VariadicView.Tree(layout, content: content)
    }
    
    struct MenuLayout: _VariadicView.UnaryViewRoot {
        @Binding var selection: V
        
        @ViewBuilder func body(children: _VariadicView.Children) -> some View {
            Picker("", selection: $selection) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    child
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .buttonStyle(.borderless)
            .padding(.trailing, -2)
        }
    }
    
    struct SegmentedLayout: _VariadicView.UnaryViewRoot {
        @Binding var selection: V
        @Binding var isHovering: Bool
        @Namespace private var namespace
        
        @ViewBuilder func body(children: _VariadicView.Children) -> some View {
            HStack {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    Button {
                        if let value = child.id(as: V.self) {
                            withAnimation {
                                selection = value
                            }
                        }
                    } label: {
                        child
                    }
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity)
                    .padding(4)
                    .background {
                        if let value = child.id(as: V.self), selection == value {
                            if isHovering {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.background.opacity(0.5))
                                    .shadow(color: .black.opacity(0.1), radius: 8)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.quinary)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct PickerPreview<V>: View where V: Hashable & Equatable {
    let elements: [V]
    @State var selection: V
    let style: LuminareCompactPicker<ForEach<[V], V, Text>, V>.PickerStyle
    
    var body: some View {
        LuminareCompactPicker(selection: $selection, borderless: false, style: style) {
            ForEach(elements, id: \.self) { element in
                Text("\(element)")
            }
        }
    }
}

#Preview {
    LuminareSection {
        LuminareCompose("Menu picker") {
            LuminareCompactPicker(selection: .constant(42), borderless: false) {
                ForEach(0..<200) { num in
                    Text("\(num)")
                }
            }
        }
        .padding(.trailing, -4)
        
        VStack {
            LuminareCompose("Segmented picker") {
            }
            
            PickerPreview(elements: ["a", "b", "c"], selection: "a", style: .segmented)
            
            PickerPreview(elements: [40, 41, 42, 43, 44], selection: 42, style: .segmented)
        }
        
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
