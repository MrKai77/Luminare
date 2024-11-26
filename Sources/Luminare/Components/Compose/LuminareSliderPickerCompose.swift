//
//  LuminareSliderPickerCompose.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

// MARK: - Slider Picker (Compose)

/// A stylized, composed picker for discrete values with a slider.
public struct LuminareSliderPickerCompose<Label, Content, V>: View where Label: View, Content: View, V: Equatable {
    public typealias ControlSize = LuminareComposeControlSize

    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation

    // MARK: Fields

    private let horizontalPadding: CGFloat
    private let controlSize: ControlSize

    @ViewBuilder private let content: (V) -> Content, label: () -> Label

    private let options: [V]
    @Binding private var selection: V

    // MARK: Initializers

    /// Initializes a ``LuminareSliderPickerCompose``.
    ///
    /// - Parameters:
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - horizontalPadding: the horizontal padding around the composed content.
    ///   - content: the content generator that accepts a value.
    ///   - label: the label.
    public init(
        _ options: [V], selection: Binding<V>,
        horizontalPadding: CGFloat = 8,
        controlSize: ControlSize = .regular,
        @ViewBuilder content: @escaping (V) -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.horizontalPadding = horizontalPadding
        self.controlSize = controlSize
        self.content = content
        self.label = label
        self.options = options
        self._selection = selection
    }

    /// Initializes a ``LuminareSliderPickerCompose`` where the label is a localized text.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - horizontalPadding: the horizontal padding around the composed content.
    ///   - content: the content generator that accepts a value.
    public init(
        _ key: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        horizontalPadding: CGFloat = 8,
        controlSize: ControlSize = .regular,
        @ViewBuilder content: @escaping (V) -> Content
    ) where Label == Text {
        self.init(
            options, selection: selection,
            horizontalPadding: horizontalPadding,
            controlSize: controlSize
        ) { value in
            content(value)
        } label: {
            Text(key)
        }
    }

    /// Initializes a ``LuminareSliderPickerCompose`` where the content is a localized text.
    ///
    /// - Parameters:
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - horizontalPadding: the horizontal padding around the composed content.
    ///   - contentKey: the content generator that accepts a value.
    ///   - label: the label.
    public init(
        _ options: [V], selection: Binding<V>,
        horizontalPadding: CGFloat = 8,
        controlSize: ControlSize = .regular,
        contentKey: @escaping (V) -> LocalizedStringKey,
        @ViewBuilder label: @escaping () -> Label
    ) where Content == Text {
        self.init(
            options, selection: selection,
            horizontalPadding: horizontalPadding,
            controlSize: controlSize
        ) { value in
            Text(contentKey(value))
        } label: {
            label()
        }
    }

    /// Initializes a ``LuminareSliderPickerCompose`` where the content and the label are localized texts.
    ///
    /// - Parameters:
    ///   - key: the `LocalizedStringKey` to look up the label text.
    ///   - options: the available options.
    ///   - selection: the binding of the selected value.
    ///   - height: the height of the composed view.
    ///   - horizontalPadding: the horizontal padding around the composed content.
    ///   - contentKey: the content generator that accepts a value.
    public init(
        _ key: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        horizontalPadding: CGFloat = 8,
        controlSize: ControlSize = .regular,
        contentKey: @escaping (V) -> LocalizedStringKey
    ) where Label == Text, Content == Text {
        self.init(
            options, selection: selection,
            horizontalPadding: horizontalPadding,
            controlSize: controlSize,
            contentKey: contentKey
        ) {
            Text(key)
        }
    }

    // MARK: Body

    public var body: some View {
        VStack {
            switch controlSize {
            case .regular:
                LuminareCompose(
                    horizontalPadding: horizontalPadding,
                    reducesTrailingSpace: true
                ) {
                    text()
                } label: {
                    label()
                }

                slider()
                    .padding(.horizontal, horizontalPadding)
                    .padding(.trailing, -2)
            case .compact:
                LuminareCompose(
                    horizontalPadding: horizontalPadding, spacing: 12,
                    reducesTrailingSpace: true
                ) {
                    HStack(spacing: 12) {
                        slider()

                        text()
                    }
                } label: {
                    label()
                }
            }
        }
        .frame(height: controlSize.height)
        .animation(animation, value: selection)
    }

    @ViewBuilder private func text() -> some View {
        content(selection)
            .contentTransition(.numericText())
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
        )
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareSliderPickerCompose",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var selection = 3

    LuminareSection {
        LuminareSliderPickerCompose(
            Array(0...4), selection: $selection,
            controlSize: .compact
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
    }

    LuminareSection {
        LuminareSliderPickerCompose(
            Array(0...4), selection: $selection
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
    }
}
