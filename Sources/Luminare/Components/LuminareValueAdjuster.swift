//
//  LuminareValueAdjuster.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareValueAdjuster<V>: View where V: Strideable, V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint, V: _FormatSpecifiable {

    public enum ControlSize {
        case regular
        case compact

        var height: CGFloat {
            switch self {
            case .regular: 70
            case .compact: 34
            }
        }
    }

    let horizontalPadding: CGFloat = 12

    let formatter: NumberFormatter
    var totalRange: V.Stride {
        V.Stride(sliderRange.upperBound) - V.Stride(sliderRange.lowerBound)
    }

    @State var isShowingTextBox: Bool = false

    // Focus
    enum FocusedField {
        case textbox
    }
    @FocusState var focusedField: FocusedField?

    let title: String
    let description: String?
    @Binding var value: V
    @State var internalValue: V
    let sliderRange: ClosedRange<V>
    let suffix: String?
    var step: V.Stride
    let upperClamp: Bool
    let lowerClamp: Bool
    let controlSize: LuminareValueAdjuster.ControlSize

    let decimalPlaces: Int

    // TODO: MAX DIGIT SPACING FOR LABEL
    public init(
        _ title: String,
        description: String? = nil,
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        suffix: String? = nil,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: LuminareValueAdjuster.ControlSize = .regular,
        decimalPlaces: Int = 0
    ) {
        self.title = title
        self.description = description
        self._value = value
        self._internalValue = State(initialValue: value.wrappedValue)
        self.sliderRange = sliderRange
        self.suffix = suffix
        self.lowerClamp = lowerClamp
        self.upperClamp = upperClamp
        self.controlSize = controlSize

        self.decimalPlaces = decimalPlaces

        self.formatter = NumberFormatter()
        self.formatter.maximumFractionDigits = decimalPlaces

        if let step = step {
            self.step = V.Stride(step)
        } else {
            self.step = 0   // Initialize first
            self.step = totalRange / 10
        }
    }

    public var body: some View {
        VStack {
            if controlSize == .regular {
                HStack {
                    Text(self.title)

                    Spacer()

                    self.labelView()
                }

                Slider(
                    value: Binding(
                        get: {
                            self.internalValue
                        },
                        set: { newValue in
                            withAnimation {
                                self.internalValue = newValue
                                self.isShowingTextBox = false
                            }
                        }
                    ),
                    in: self.sliderRange
                )
            } else {
                HStack(spacing: 12) {
                    Text(self.title)

                    Spacer(minLength: 0)

                    HStack(spacing: 12) {
                        Slider(
                            value: Binding(
                                get: {
                                    self.value
                                },
                                set: { newValue in
                                    withAnimation {
                                        self.value = newValue
                                        self.isShowingTextBox = false
                                    }
                                }
                            ),
                            in: self.sliderRange
                        )

                        self.labelView()
                    }
                    .frame(width: 270)
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(height: self.controlSize.height)
        .onChange(of: self.internalValue) { _ in
            self.value = self.internalValue
        }
    }

    @ViewBuilder
    func labelView() -> some View {
        HStack {
            HStack {
                if self.isShowingTextBox {
                    TextField(
                        .init(""),
                        value: Binding(
                            get: {
                                self.internalValue
                            },
                            set: {
                                if lowerClamp && upperClamp {
                                    self.internalValue = $0.clamped(to: sliderRange)
                                } else if lowerClamp {
                                    self.internalValue = max(self.sliderRange.lowerBound, $0)
                                } else if upperClamp {
                                    self.internalValue = min(self.sliderRange.upperBound, $0)
                                } else {
                                    self.internalValue = $0
                                }
                            }
                        ),
                        formatter: formatter,
                        onCommit: {
                            withAnimation(.easeOut(duration: 0.1)) {
                                self.isShowingTextBox.toggle()
                            }
                        }
                    )
                    .focused($focusedField, equals: .textbox)
                    .labelsHidden()
                    .textFieldStyle(.plain)
                    .padding(.trailing, -8)
                } else {
                    Button {
                        withAnimation(.easeOut(duration: 0.1)) {
                            self.isShowingTextBox.toggle()
                            self.focusedField = .textbox
                        }
                    } label: {
                        Text("\(self.internalValue, specifier: "%.\(decimalPlaces)f")")
                            .contentTransition(.numericText())
                            .multilineTextAlignment(.trailing)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, suffix == nil ? 0 : -6)
                }

                if let suffix = suffix {
                    Text(suffix)
                }
            }
            .monospaced()
            .padding(4)
            .padding(.horizontal, 4)
            .background {
                ZStack {
                    Capsule(style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 1)

                    if self.isShowingTextBox {
                        Capsule(style: .continuous)
                            .foregroundStyle(.quinary)
                    } else {
                        Capsule(style: .continuous)
                            .foregroundStyle(.quinary.opacity(0.5))
                    }
                }
            }
            .fixedSize()
            .clipShape(Capsule(style: .continuous))
        }
    }
}

extension Comparable {
    fileprivate func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
