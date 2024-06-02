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

    let horizontalPadding: CGFloat = 8

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

    let title: LocalizedStringKey
    let infoView: LuminareInfoView?
    @Binding var value: V
    @State var internalValue: V
    let sliderRange: ClosedRange<V>
    let suffix: LocalizedStringKey?
    var step: V.Stride
    let upperClamp: Bool
    let lowerClamp: Bool
    let controlSize: LuminareValueAdjuster.ControlSize

    let decimalPlaces: Int

    // TODO: MAX DIGIT SPACING FOR LABEL
    public init(
        _ title: LocalizedStringKey,
        info: LuminareInfoView? = nil,
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        suffix: LocalizedStringKey? = nil,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: LuminareValueAdjuster.ControlSize = .regular,
        decimalPlaces: Int = 0
    ) {
        self.title = title
        self.infoView = info
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
                    titleView()

                    Spacer()

                    labelView()
                }

                sliderView()
            } else {
                HStack(spacing: 12) {
                    titleView()

                    Spacer(minLength: 0)

                    HStack(spacing: 12) {
                        sliderView()

                        labelView()
                    }
                    .frame(width: 270)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: controlSize.height)
        .onChange(of: internalValue) { _ in
            value = internalValue
        }
    }

    func titleView() -> some View {
        HStack(spacing: 0) {
            Text(title)

            if let infoView = infoView {
                infoView
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    func sliderView() -> some View {
        Slider(
            value: Binding(
                get: {
                    internalValue
                },
                set: { newValue in
                    withAnimation(.smooth(duration: 0.25)) {
                        internalValue = newValue
                        isShowingTextBox = false
                    }
                }
            ),
            in: sliderRange
        )
    }

    @ViewBuilder
    func labelView() -> some View {
        HStack {
            if isShowingTextBox {
                TextField(
                    .init(""),
                    value: Binding(
                        get: {
                            internalValue
                        },
                        set: {
                            if lowerClamp && upperClamp {
                                internalValue = $0.clamped(to: sliderRange)
                            } else if lowerClamp {
                                internalValue = max(sliderRange.lowerBound, $0)
                            } else if upperClamp {
                                internalValue = min(sliderRange.upperBound, $0)
                            } else {
                                internalValue = $0
                            }
                        }
                    ),
                    formatter: formatter,
                    onCommit: {
                        withAnimation(.easeOut(duration: 0.1)) {
                            isShowingTextBox.toggle()
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
                        isShowingTextBox.toggle()
                        focusedField = .textbox
                    }
                } label: {
                    Text("\(internalValue, specifier: "%.\(decimalPlaces)f")")
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
        .frame(maxWidth: 150)
        .monospaced()
        .padding(4)
        .padding(.horizontal, 4)
        .background {
            ZStack {
                Capsule()
                    .strokeBorder(.quaternary, lineWidth: 1)

                if isShowingTextBox {
                    Capsule()
                        .foregroundStyle(.quinary)
                } else {
                    Capsule()
                        .foregroundStyle(.quinary.opacity(0.5))
                }
            }
        }
        .fixedSize()
        .clipShape(.capsule)
    }
}

extension Comparable {
    fileprivate func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
