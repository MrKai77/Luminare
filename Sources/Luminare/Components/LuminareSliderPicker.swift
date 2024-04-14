//
//  LuminareSliderPicker.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct LuminareSliderPicker<V>: View where V: Equatable {

    let height: CGFloat = 70

    let title: String

    let options: [V]
    @Binding var selection: V

    let label: (V) -> String

    public init(_ title: String, _ options: [V], selection: Binding<V>, label: @escaping (V) -> String) {
        self.title = title
        self.options = options
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        VStack {
            HStack {
                Text(self.title)

                Spacer()

                labelView()
            }

            Slider(
                value: Binding<Double>(
                    get: {
                        Double(self.options.firstIndex(where: { $0 == self.selection }) ?? 0)
                    },
                    set: { newIndex in
                        withAnimation {
                            self.selection = self.options[Int(newIndex)]
                        }
                    }
                ),
                in: 0 ... Double(options.count - 1),
                step: 1
            )
        }
        .padding(.horizontal, 8)
        .frame(height: height)
    }

    @ViewBuilder
    func labelView() -> some View {
        HStack {
            Text(self.label(self.selection))
                .contentTransition(.numericText())

                .monospaced()
                .padding(4)
                .padding(.horizontal, 4)
                .background {
                    ZStack {
                        Capsule(style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 1)

                        Capsule(style: .continuous)
                            .foregroundStyle(.quinary.opacity(0.5))
                    }
                }
                .fixedSize()
                .clipShape(Capsule(style: .continuous))
        }
    }
}
