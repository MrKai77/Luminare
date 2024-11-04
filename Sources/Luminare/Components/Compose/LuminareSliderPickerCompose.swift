//
//  LuminareSliderPickerCompose.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

// MARK: - Slider Picker (Compose)

public struct LuminareSliderPickerCompose<Label, Content, V>: View where Label: View, Content: View, V: Equatable {
    // MARK: Environments
    
    @Environment(\.luminareAnimation) private var animation
    
    // MARK: Fields
    
    private let height: CGFloat
    private let horizontalPadding: CGFloat
    
    @ViewBuilder private let content: (V) -> Content
    @ViewBuilder private let label: () -> Label

    private let options: [V]
    @Binding private var selection: V

    // MARK: Initializers

    public init(
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        @ViewBuilder content: @escaping (V) -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.content = content
        self.label = label
        self.options = options
        self._selection = selection
    }
    
    public init(
        _ key: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        @ViewBuilder content: @escaping (V) -> Content
    ) where Label == Text {
        self.init(
            options, selection: selection,
            height: height,
            horizontalPadding: horizontalPadding
        ) { value in
            content(value)
        } label: {
            Text(key)
        }
    }
    
    public init(
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        contentKey: @escaping (V) -> LocalizedStringKey,
        @ViewBuilder label: @escaping () -> Label
    ) where Content == Text {
        self.init(
            options, selection: selection,
            height: height,
            horizontalPadding: horizontalPadding
        ) { value in
            Text(contentKey(value))
        } label: {
            label()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        contentKey: @escaping (V) -> LocalizedStringKey
    ) where Label == Text, Content == Text {
        self.init(
            options, selection: selection,
            height: height,
            horizontalPadding: horizontalPadding,
            contentKey: contentKey
        ) {
            Text(key)
        }
    }
    
    // MARK: Body

    public var body: some View {
        VStack {
            LuminareCompose(horizontalPadding: horizontalPadding, reducesTrailingSpace: true) {
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
            } label: {
                label()
            }

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
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: height)
        .animation(animation, value: selection)
    }
}

// MARK: - Preview

#Preview {
    LuminareSection {
        LuminareSliderPickerCompose(
            "Slider picker",
            ["0", "1", "e", "i", "π"], selection: .constant("i")
        ) { value in
            Text("\(value)")
                .monospaced()
        }
    }
    .padding()
}
