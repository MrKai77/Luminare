//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI

/// The style for a ``LuminareCompactPicker``.
public enum LuminareCompactPickerStyle {
    /// A menu that presents a popup list to toggle selection.
    ///
    /// Works great in most cases, especially with an enormous amount of choises.
    case menu
    /// A row of segmented knobs, each representing a selectable value.
    ///
    /// Often used for brief, flatten choises .
    ///
    /// - Parameters:
    ///   - hasDividers: whether to display dividers between segmented knobs.
    case segmented(hasDividers: Bool = true)

    var style: any PickerStyle {
        switch self {
        case .menu: .menu
        case .segmented: .segmented
        }
    }
}

// MARK: - Compact Picker

/// A stylized, compact picker.
public struct LuminareCompactPicker<Content, V>: View where Content: View, V: Hashable & Equatable {
    public typealias PickerStyle = LuminareCompactPickerStyle

    // MARK: Environments

    @Environment(\.luminareAnimationFast) private var animationFast

    // MARK: Fields

    private let elementMinHeight: CGFloat, horizontalPadding: CGFloat, cornerRadius: CGFloat
    private let isBordered: Bool
    private let style: PickerStyle

    @Binding private var selection: V
    @ViewBuilder private let content: () -> Content

    @State private var isHovering: Bool = false

    // MARK: Initializers

    /// Initializes a ``LuminareCompactPicker``.
    ///
    /// - Parameters:
    ///   - selection: the binding of the selected value.
    ///   - elementMinHeight: the minimum height of the inner view.
    ///   - horizontalPadding: the horizontal padding of the inner view.
    ///   - cornerRadius: the radius of the corners..
    ///   - isBordered: whether to display a border while not hovering.
    ///   - style: the ``LuminareCompactPickerStyle`` that defines the style of the picker.
    ///   - content: the selectable values.
    public init(
        selection: Binding<V>,
        elementMinHeight: CGFloat = 30, horizontalPadding: CGFloat = 4,
        cornerRadius: CGFloat = 8,
        isBordered: Bool = true,
        style: PickerStyle = .menu,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.elementMinHeight = elementMinHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.isBordered = isBordered
        self.style = style
        self.content = content
    }

    // MARK: Body

    public var body: some View {
        Group {
            switch style {
            case .menu:
                Picker("", selection: $selection, content: content)
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .buttonStyle(.borderless)
                    .padding(.trailing, -2)
            case .segmented(let hasDividers):
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
        .modifier(LuminareHoverable(
            elementMinHeight: elementMinHeight,
            horizontalPadding: horizontalPadding,
            cornerRadius: cornerRadius,
            isBordered: isBordered
        ))
    }

    @ViewBuilder private func variadic<Layout>(
        layout: Layout, content: () -> some View
    ) -> some View where Layout: _VariadicView.ViewRoot {
        _VariadicView.Tree(layout, content: content)
    }

    // MARK: - Layouts

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
                                knobBackground(isCurrentlyHovering: hoveringKnobOffset == index)
                                    .matchedGeometryEffect(
                                        id: "knob", in: namespace
                                    )
                            } else if hoveringKnobOffset == index {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(.quinary)
                            }
                        }
                        .onHover { hover in
                            withAnimation(animationFast) {
                                hoveringKnobOffset = hover ? index : nil
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

        @ViewBuilder private func knobBackground(isCurrentlyHovering: Bool) -> some View {
            Group {
                if isHovering {
                    Rectangle()
                        .foregroundStyle(.background.opacity(0.8))
                } else {
                    Rectangle()
                        .foregroundStyle(.quinary)
                }
            }
            .overlay {
                if isCurrentlyHovering {
                    Rectangle()
                        .foregroundStyle(.background.opacity(0.2))
                        .blendMode(.luminosity)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
        }

        struct SegmentedKnob: View {
            @Environment(\.luminareAnimation) private var animation
            @Environment(\.luminareAnimationFast) private var animationFast

            var cornerRadius: CGFloat

            @Binding var selection: V
            var value: V
            var view: _VariadicView.Children.Element

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
        LuminareCompactPicker(selection: $selection, isBordered: isBordered, style: style) {
            ForEach(elements, id: \.self) { element in
                Text("\(element)")
            }
        }
    }
}

@available(macOS 15.0, *)
#Preview(
    "LuminareCompactPicker",
    traits: .sizeThatFitsLayout
) {
    LuminareSection {
        LuminareCompose("Button", reducesTrailingSpace: true) {
            Button {
            } label: {
                Text("42")
                    .frame(height: 30)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
        }

        LuminareCompose("Pick from a menu", reducesTrailingSpace: true) {
            PickerPreview(elements: Array(0..<200), selection: 42, style: .menu)
        }

        VStack {
            LuminareCompose("Pick from segments") {
            }

            PickerPreview(
                elements: ["macOS", "Linux", "Windows"],
                selection: "macOS",
                isBordered: false, style: .segmented(hasDividers: false)
            )
            .environment(\.luminareAnimation, .bouncy)

            PickerPreview(elements: [40, 41, 42, 43, 44], selection: 42, style: .segmented())
        }
    }
}
