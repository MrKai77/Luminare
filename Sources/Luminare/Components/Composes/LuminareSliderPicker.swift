//
//  LuminareSliderPicker.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

// MARK: - Slider Picker (Compose)

/// A stylized, composed picker for discrete values with a slider.
public struct LuminareSliderPicker<Label, Content, V>: View where Label: View, Content: View, V: Equatable {
    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareComposeLayout) private var layout

    // MARK: Fields

    @ViewBuilder private var content: (V) -> Content, label: () -> Label

    private let options: [V]
    @Binding private var selection: V

    @State private var lastSelection: V
    @State private var isSliderHovering: Bool = false
    @State private var isSliderDebouncedHovering: Bool = false
    @State private var isSliderEditing: Bool = false

    // MARK: Initializers

    /// Initializes a ``LuminareSliderPicker``.
    ///
    /// - Parameters:
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - content: the content generator that accepts a value.
    ///   - label: the label.
    public init(
        _ options: [V], selection: Binding<V>,
        @ViewBuilder content: @escaping (V) -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.label = label
        self.options = options
        self._selection = selection
        self.lastSelection = selection.wrappedValue
    }

    /// Initializes a ``LuminareSliderPicker`` where the label is a localized text.
    ///
    /// - Parameters:
    ///   - title: the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - content: the content generator that accepts a value.
    public init(
        _ title: some StringProtocol,
        _ options: [V], selection: Binding<V>,
        @ViewBuilder content: @escaping (V) -> Content
    ) where Label == Text {
        self.init(
            options, selection: selection
        ) { value in
            content(value)
        } label: {
            Text(title)
        }
    }

    /// Initializes a ``LuminareSliderPicker`` where the label is a localized text.
    ///
    /// - Parameters:
    ///   - titleKey: the `LocalizedStringKey` to look up the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - content: the content generator that accepts a value.
    public init(
        _ titleKey: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        @ViewBuilder content: @escaping (V) -> Content
    ) where Label == Text {
        self.init(
            options, selection: selection
        ) { value in
            content(value)
        } label: {
            Text(titleKey)
        }
    }

    /// Initializes a ``LuminareSliderPicker`` where the content is a localized text.
    ///
    /// - Parameters:
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - content: the content generator that accepts a value.
    ///   - label: the label.
    public init(
        _ options: [V], selection: Binding<V>,
        content: @escaping (V) -> some StringProtocol,
        @ViewBuilder label: @escaping () -> Label
    ) where Content == Text {
        self.init(
            options, selection: selection
        ) { value in
            Text(content(value))
        } label: {
            label()
        }
    }

    /// Initializes a ``LuminareSliderPicker`` where the content is a localized text.
    ///
    /// - Parameters:
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - contentKey: the content generator that accepts a value.
    ///   - label: the label.
    public init(
        _ options: [V], selection: Binding<V>,
        contentKey: @escaping (V) -> LocalizedStringKey,
        @ViewBuilder label: @escaping () -> Label
    ) where Content == Text {
        self.init(
            options, selection: selection
        ) { value in
            Text(contentKey(value))
        } label: {
            label()
        }
    }

    /// Initializes a ``LuminareSliderPicker`` where the content and the label are localized texts.
    ///
    /// - Parameters:
    ///   - title: the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - content: the content generator that accepts a value.
    public init(
        _ title: some StringProtocol,
        _ options: [V], selection: Binding<V>,
        content: @escaping (V) -> some StringProtocol
    ) where Label == Text, Content == Text {
        self.init(
            options, selection: selection,
            content: content
        ) {
            Text(title)
        }
    }

    /// Initializes a ``LuminareSliderPicker`` where the content and the label are localized texts.
    ///
    /// - Parameters:
    ///   - title: the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - contentKey: the content generator that accepts a value.
    public init(
        _ title: some StringProtocol,
        _ options: [V], selection: Binding<V>,
        contentKey: @escaping (V) -> LocalizedStringKey
    ) where Label == Text, Content == Text {
        self.init(
            options, selection: selection,
            contentKey: contentKey
        ) {
            Text(title)
        }
    }

    /// Initializes a ``LuminareSliderPicker`` where the content and the label are localized texts.
    ///
    /// - Parameters:
    ///   - titleKey: the `LocalizedStringKey` to look up the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - content: the content generator that accepts a value.
    public init(
        _ titleKey: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        content: @escaping (V) -> some StringProtocol
    ) where Label == Text, Content == Text {
        self.init(
            options, selection: selection,
            content: content
        ) {
            Text(titleKey)
        }
    }

    /// Initializes a ``LuminareSliderPicker`` where the content and the label are localized texts.
    ///
    /// - Parameters:
    ///   - titleKey: the `LocalizedStringKey` to look up the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - contentKey: the content generator that accepts a value.
    public init(
        _ titleKey: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        contentKey: @escaping (V) -> LocalizedStringKey
    ) where Label == Text, Content == Text {
        self.init(
            options, selection: selection,
            contentKey: contentKey
        ) {
            Text(titleKey)
        }
    }

    // MARK: Body

    public var body: some View {
        VStack {
            switch layout {
            case .regular:
                LuminareCompose {
                    text()
                } label: {
                    HStack(spacing: 4) {
                        label()
                    }
                }
                .luminareComposeStyle(.inline)

                slider()
                    .onHover { isHovering in
                        isSliderHovering = isHovering
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.trailing, -2)
            case .compact:
                LuminareCompose(spacing: 12) {
                    HStack(spacing: 12) {
                        slider()
                            .onHover { isHovering in
                                isSliderHovering = isHovering
                            }

                        if !isSliderDebouncedHovering, !isSliderEditing {
                            text()
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        label()
                    }
                }
                .luminareComposeStyle(.inline)
            }
        }
        .animation(animation, value: selection)
        .animation(animation, value: isSliderHovering)
        .animation(animation, value: isSliderDebouncedHovering)
        .animation(animation, value: isSliderEditing)
        .booleanThrottleDebounced(isSliderHovering) { debouncedValue in
            isSliderDebouncedHovering = debouncedValue
        }
    }

    @ViewBuilder private func text() -> some View {
        content(selection)
            .contentTransition(.numericText(countsDown: countsDown))
            .multilineTextAlignment(.trailing)
            .padding(4)
            .padding(.horizontal, 4)
            .background {
                ZStack {
                    Capsule()
                        .strokeBorder(.quaternary, lineWidth: 1)

                    Capsule()
                        .foregroundStyle(.quinary.opacity(0.5))
                }
            }
            .fixedSize()
            .clipShape(.capsule)
            .onChange(of: selection) { value in
                DispatchQueue.main.async {
                    lastSelection = value
                }
            }
    }

    @ViewBuilder private func slider() -> some View {
        Slider(
            value: Binding<Double>(
                get: {
                    Double(options.firstIndex(where: { $0 == selection }) ?? 0)
                },
                set: { newIndex in
                    selection = options[Int(newIndex)]
                }
            ),
            in: 0...Double(options.count - 1),
            step: 1
        ) { isEditing in
            isSliderEditing = isEditing
        }
    }

    private var countsDown: Bool {
        options.firstIndex(of: selection)! > options.firstIndex(of: lastSelection)!
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareSliderPicker",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var selection = 3

    LuminareSection {
        LuminareSliderPicker(
            Array(0...4),
            selection: $selection
        ) { value in
            Text("\(value) is Chosen")
                .monospaced()
        } label: {
            VStack(alignment: .leading) {
                Text("Slide to pick a value")

                Text("Composed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        LuminareSliderPicker(
            Array(0...4),
            selection: $selection
        ) { value in
            Text("\(value) is Chosen")
                .monospaced()
        } label: {
            VStack(alignment: .leading) {
                Text("Slide to pick a value")

                Text("Composed, Compact")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .luminareComposeLayout(.compact)

        LuminareSliderPicker(
            Array(0...4),
            selection: $selection
        ) { value in
            Text("\(value) is Chosen")
                .monospaced()
        } label: {
            Text("With an info")

            LuminarePopover {
                Text("Popover")
                    .padding(4)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .luminareComposeLayout(.compact)
    }
}
