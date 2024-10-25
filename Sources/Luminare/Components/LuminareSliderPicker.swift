//
//  LuminareSliderPicker.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct LuminareSliderPicker<Label, Content, Info, V>: View
where Label: View, Content: View, Info: View, V: Equatable {
    private let height: CGFloat
    private let horizontalPadding: CGFloat
    
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let content: (V) -> Content
    @ViewBuilder private let info: () -> LuminareInfoView<Info>

    private let options: [V]
    @Binding private var selection: V

    public init(
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping (V) -> Content,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.label = label
        self.content = content
        self.info = info
        self.options = options
        self._selection = selection
    }
    
    public init(
        _ key: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        contentKey: @escaping (V) -> LocalizedStringKey,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text, Content == Text {
        self.init(
            options, selection: selection,
            height: height,
            horizontalPadding: horizontalPadding
        ) {
            Text(key)
        } content: { value in
            Text(contentKey(value))
        } info: {
            info()
        }
    }
    
    public init(
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping (V) -> Content
    ) where Info == EmptyView {
        self.init(
            options, selection: selection,
            height: height,
            horizontalPadding: horizontalPadding
        ) {
            label()
        } content: { value in
            content(value)
        } info: {
            LuminareInfoView()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        _ options: [V], selection: Binding<V>,
        height: CGFloat = 70,
        horizontalPadding: CGFloat = 8,
        contentKey: @escaping (V) -> LocalizedStringKey
    ) where Label == Text, Content == Text, Info == EmptyView {
        self.init(
            key,
            options, selection: selection,
            height: height,
            horizontalPadding: horizontalPadding,
            contentKey: contentKey
        ) {
            LuminareInfoView()
        }
    }

    public var body: some View {
        VStack {
            LuminareLabeledContent(horizontalPadding: horizontalPadding) {
                content(selection)
                    .contentTransition(.numericText())
                    .multilineTextAlignment(.trailing)
                    .monospaced()
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
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: height)
        .animation(LuminareConstants.animation, value: selection)
    }
}
