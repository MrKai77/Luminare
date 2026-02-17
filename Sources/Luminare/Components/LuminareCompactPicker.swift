//
//  LuminareCompactPicker.swift
//  Luminare
//
//  Created by KrLite on 2024/10/26.
//

import SwiftUI
import VariadicViews

/// The style for a ``LuminareCompactPicker``.
public enum LuminareCompactPickerStyle: Hashable, Equatable, Codable, Sendable {
    /// A menu that presents a popup list to toggle selection.
    ///
    /// Works great in most cases, especially with an enormous amount of choises.
    case menu

    /// A row of segmented knobs, each representing a selectable value.
    ///
    /// Often used for brief, flatten choises.
    case segmented
}

// MARK: - Compact Picker

/// A stylized, compact picker.
public struct LuminareCompactPicker<Content, V>: View where Content: View, V: Hashable & Equatable {
    public typealias PickerStyle = LuminareCompactPickerStyle

    // MARK: Environments

    @Environment(\.luminareCompactPickerStyle) private var style

    // MARK: Fields

    @Binding private var selection: V
    @ViewBuilder private var content: () -> Content

    @State private var isHovering: Bool = false

    // MARK: Initializers

    /// Initializes a ``LuminareCompactPicker``.
    ///
    /// - Parameters:
    ///   - selection: the binding of the selected value.
    ///   - content: the selectable values.
    public init(
        selection: Binding<V>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
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
            case .segmented:
                UnaryVariadicView(content()) { children in
                    SegmentedVariadic(
                        children: children,
                        isHovering: isHovering,
                        selection: $selection
                    )
                }
                .padding(.horizontal, 4)
            }
        }
        .modifier(LuminareHoverableModifier(isHovering: isHovering))
        .onHover { isHovering = $0 }
    }

    // MARK: - Layout

    struct SegmentedVariadic: View {
        @Environment(\.luminareMinHeight) private var minHeight
        @Environment(\.luminareHasDividers) private var hasDividers

        var children: VariadicViewChildren
        var isHovering: Bool

        @Binding var selection: V

        @Namespace private var namespace

        var body: some View {
            HStack(spacing: 4) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    if let value = child.id(as: V.self) {
                        SegmentedKnob(
                            child: child,
                            namespace: namespace,
                            isParentHovering: isHovering,
                            selection: $selection,
                            value: value,
                            index: index,
                            maxIndex: children.count - 1
                        )
                        .foregroundStyle(isHovering && selection == value ? .primary : .secondary)
                        .zIndex(1)

                        if hasDividers,
                           child.id != children.last?.id {
                            Divider()
                                .frame(height: minHeight / 2)
                                .zIndex(0)
                        }
                    }
                }
            }
        }

        struct SegmentedKnob: View {
            @Environment(\.luminareAnimation) private var animation
            @Environment(\.luminareMinHeight) private var minHeight
            @Environment(\.luminareCornerRadii) private var cornerRadii
            @Environment(\.luminareBorderedStates) private var borderedStates

            var child: VariadicViewChildren.Element
            var namespace: Namespace.ID
            var isParentHovering: Bool

            @Binding var selection: V
            var value: V
            var index: Int
            var maxIndex: Int

            @State private var isHovering: Bool = false

            var body: some View {
                Button {
                    withAnimation(animation) {
                        selection = value
                    }
                } label: {
                    child
                        .frame(maxWidth: .infinity, minHeight: minHeight - 8)
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.borderless)
                .onHover { isHovering = $0 }
                .background {
                    Group {
                        if selection == value {
                            knob()
                                .matchedGeometryEffect(
                                    id: "knob", in: namespace
                                )
                        } else if isHovering {
                            UnevenRoundedRectangle(cornerRadii: constrainedCornerRadii)
                                .foregroundStyle(.quinary)
                        }
                    }
                }
                .padding(.vertical, 4)
                .frame(minHeight: minHeight)
            }

            private var constrainedCornerRadii: RectangleCornerRadii {
                let baseRadii = if borderedStates.contains(.normal) || isParentHovering {
                    cornerRadii.inset(by: 2, minRadius: 2)
                } else {
                    cornerRadii
                }

                return .init(
                    topLeading: index == 0 ? baseRadii.topLeading : 2,
                    bottomLeading: index == 0 ? baseRadii.bottomLeading : 2,
                    bottomTrailing: index == maxIndex ? baseRadii.bottomTrailing : 2,
                    topTrailing: index == maxIndex ? baseRadii.topTrailing : 2
                )
            }

            private func knob() -> some View {
                Group {
                    if isParentHovering {
                        Rectangle()
                            .foregroundStyle(.background.opacity(0.8))
                    } else {
                        // The `.blendMode()` prevents `.quinary` style to be clipped
                        Rectangle()
                            .foregroundStyle(.quinary.blendMode(.luminosity))
                    }
                }
                .overlay {
                    if isHovering {
                        Rectangle()
                            .foregroundStyle(.background.opacity(0.2))
                            .blendMode(.luminosity)
                    }
                }
                .clipShape(.rect(cornerRadii: constrainedCornerRadii))
            }
        }
    }
}

// MARK: - Preview

private struct PickerPreview<V>: View where V: Hashable & Equatable {
    let elements: [V]
    @State var selection: V

    var body: some View {
        LuminareCompactPicker(selection: $selection) {
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
        LuminareCompose("Button") {
            Button {} label: {
                Text("42")
            }
        }

        LuminareCompose("Pick from a menu") {
            PickerPreview(elements: Array(0 ..< 200), selection: 42)
        }

        LuminareCompose("Pick from segments") {
            PickerPreview(elements: ["Inline", "Fixed"], selection: "Inline")
                .luminareCompactPickerStyle(.segmented)
                .luminareComposeIgnoreSafeArea(edges: .trailing)
        }

        PickerPreview(
            elements: ["macOS", "Linux", "Windows"],
            selection: "macOS"
        )
        .luminareCompactPickerStyle(.segmented)
        .luminareCornerRadius(12)

        PickerPreview(elements: [40, 41, 42, 43, 44], selection: 42)
            .luminareCompactPickerStyle(.segmented)
            .luminareRoundingBehavior(bottom: true)
    }
}
