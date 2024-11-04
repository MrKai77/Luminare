//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI

public enum LuminareCompactPickerStyle {
    case menu
    case segmented
    
    var style: any PickerStyle {
        switch self {
        case .menu: .menu
        case .segmented: .segmented
        }
    }
}

// MARK: - Compact Picker

public struct LuminareCompactPicker<Content, V>: View
where Content: View, V: Hashable & Equatable {
    public typealias PickerStyle = LuminareCompactPickerStyle
    
    // MARK: Environments
    
    @Environment(\.luminareAnimationFast) private var animationFast
    
    // MARK: Fields
    
    private let elementMinHeight: CGFloat
    private let horizontalPadding: CGFloat
    private let cornerRadius: CGFloat
    private let isBordered: Bool
    private let hasDividers: Bool
    private let style: PickerStyle
    
    @Binding private var selection: V
    @ViewBuilder private let content: () -> Content
    
    @State private var isHovering: Bool = false
    
    // MARK: Initializers
    
    public init(
        selection: Binding<V>,
        elementMinHeight: CGFloat = 30, horizontalPadding: CGFloat = 4,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true,
        hasDividers: Bool = true,
        style: PickerStyle = .menu,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.isBordered = isBordered
        self.hasDividers = hasDividers
        self.style = style
        self.content = content
    }
    
    // MARK: Body
    
    public var body: some View {
        Group {
            switch style {
            case .menu:
                _VariadicView.Tree(MenuLayout(selection: $selection), content: content)
            case .segmented:
                _VariadicView.Tree(SegmentedLayout(
                    elementMinHeight: elementMinHeight,
                    cornerRadius: cornerRadius,
                    hasDividers: hasDividers,
                    selection: $selection, isHovering: $isHovering
                ), content: content)
            }
        }
        .onHover { hover in
            withAnimation(animationFast) {
                isHovering = hover
            }
        }
        .frame(minHeight: elementMinHeight)
        .padding(.horizontal, horizontalPadding)
        .background {
            if isHovering {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary, lineWidth: 1)
            } else if isBordered {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.quaternary.opacity(0.7), lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.clear, lineWidth: 1)
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
        .animation(animationFast, value: isHovering)
    }
    
    @ViewBuilder private func variadic<Layout>(
        layout: Layout, content: () -> some View
    ) -> some View where Layout: _VariadicView.ViewRoot {
        _VariadicView.Tree(layout, content: content)
    }
    
    // MARK: Layouts
    
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
        @Environment(\.luminareAnimationFast) private var animationFast
        
        let elementMinHeight: CGFloat
        let cornerRadius: CGFloat
        let hasDividers: Bool
        
        @Binding var selection: V
        @Binding var isHovering: Bool
        
        @Namespace private var namespace
        @State private var hoveringKnobOffset: Int?
        @State private var isHolding: Bool = false
        
        private var mouseLocation: NSPoint { NSEvent.mouseLocation }
        
        @ViewBuilder func body(children: _VariadicView.Children) -> some View {
            HStack {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    if let value = child.id(as: V.self) {
                        SegmentedKnob(
                            cornerRadius: cornerRadius,
                            selection: $selection, value: value,
                            view: child
                        )
                        .foregroundStyle(isHovering && selection == value ? .primary : .secondary)
                        .background {
                            if selection == value {
                                Group {
                                    if isHovering {
                                        Rectangle()
                                            .foregroundStyle(.background.opacity(0.7))
                                            .shadow(color: .black.opacity(0.1), radius: 8)
                                    } else {
                                        Rectangle()
                                            .foregroundStyle(.quinary)
                                    }
                                }
                                .overlay {
                                    if hoveringKnobOffset == index {
                                        Rectangle()
                                            .foregroundStyle(.background.opacity(0.2))
                                            .blendMode(.luminosity)
                                    }
                                }
                                .clipShape(.rect(cornerRadius: cornerRadius))
                                .matchedGeometryEffect(
                                    id: "knob", in: namespace
                                )
                            }
                        }
                        .onHover { hover in
                            if selection == value {
                                withAnimation(animationFast) {
                                    if hover {
                                        hoveringKnobOffset = index
                                    } else {
                                        hoveringKnobOffset = nil
                                    }
                                }
                            }
                        }
                        .onChange(of: selection) { newValue in
                            if newValue == value {
                                withAnimation(animationFast) {
                                    hoveringKnobOffset = index
                                }
                            }
                        }
                        .zIndex(1)
                        
                        if hasDividers, child.id != children.last?.id {
                            Divider()
                                .frame(width: 0, height: elementMinHeight / 2)
                                .zIndex(0)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        
        struct SegmentedKnob: View {
            @Environment(\.luminareAnimation) private var animation
            @Environment(\.luminareAnimationFast) private var animationFast
            
            let cornerRadius: CGFloat
            
            @Binding var selection: V
            let value: V
            let view: _VariadicView.Children.Element
            
            @State private var isHovering: Bool = false
            
            var body: some View {
                Button {
                    withAnimation(animation) {
                        selection = value
                    }
                } label: {
                    view
                        .frame(maxWidth: .infinity)
                        .padding(4)
                }
                .buttonStyle(.borderless)
                .onHover { hover in
                    withAnimation(animationFast) {
                        isHovering = hover
                    }
                }
                .background {
                    Group {
                        if selection != value, isHovering {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundStyle(.background.opacity(0.2))
                        }
                    }
                    .blendMode(.luminosity)
                }
            }
        }
    }
}

// MARK: - Preview

private struct PickerPreview<V>: View where V: Hashable & Equatable {
    let elements: [V]
    @State var selection: V
    var isBordered: Bool = true
    var hasDividers: Bool = true
    let style: LuminareCompactPickerStyle
    
    var body: some View {
        LuminareCompactPicker(selection: $selection, isBordered: isBordered, hasDividers: hasDividers, style: style) {
            ForEach(elements, id: \.self) { element in
                Text("\(element)")
            }
        }
    }
}

#Preview {
    LuminareSection {
        LuminareCompose("Menu picker", reducesTrailingSpace: true) {
            PickerPreview(elements: Array(0..<200), selection: 42, style: .menu)
        }
        
        VStack {
            LuminareCompose("Segmented picker") {
            }
            
            PickerPreview(elements: ["macOS", "Linux", "Windows"], selection: "macOS", isBordered: false, hasDividers: false, style: .segmented)
                .environment(\.luminareAnimation, .bouncy)
            
            PickerPreview(elements: [40, 41, 42, 43, 44], selection: 42, style: .segmented)
        }
        
        LuminareCompose("Button", reducesTrailingSpace: true) {
            Button {
                
            } label: {
                Text("Test")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }
    }
    .padding()
}
