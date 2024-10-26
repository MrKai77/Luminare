//
//  LuminareValueAdjusterCompose.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareValueAdjusterCompose<Label, Info, Suffix, V>: View
where Label: View, Info: View, Suffix: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
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

    private let horizontalPadding: CGFloat
    private let disabled: Bool

    private let formatter: NumberFormatter
    private var totalRange: V {
        sliderRange.upperBound - sliderRange.lowerBound
    }

    @State private var isShowingTextBox = false

    enum FocusedField {
        case textbox
    }

    @FocusState private var focusedField: FocusedField?

    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let suffix: () -> Suffix
    @ViewBuilder private let info: () -> LuminareInfoView<Info>
    
    @Binding private var value: V
    private let sliderRange: ClosedRange<V>
    private var step: V
    private let upperClamp: Bool
    private let lowerClamp: Bool
    private let controlSize: LuminareValueAdjusterCompose.ControlSize
    private let decimalPlaces: Int
    
    @State var eventMonitor: AnyObject?

    // TODO: max digit spacing for label
    public init(
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: LuminareValueAdjusterCompose.ControlSize = .regular,
        decimalPlaces: Int = 0,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder suffix: @escaping () -> Suffix,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) {
        self.label = label
        self.suffix = suffix
        self.info = info
        
        self._value = value
        self.sliderRange = sliderRange
        self.lowerClamp = lowerClamp
        self.upperClamp = upperClamp
        self.controlSize = controlSize

        self.decimalPlaces = decimalPlaces

        self.formatter = NumberFormatter()
        formatter.maximumFractionDigits = 5

        if let step {
            self.step = step
        } else {
            self.step = 1
        }
        
        self.horizontalPadding = horizontalPadding
        self.disabled = disabled
    }
    
    public init(
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: LuminareValueAdjusterCompose.ControlSize = .regular,
        decimalPlaces: Int = 0,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder suffix: @escaping () -> Suffix
    ) where Info == EmptyView {
        self.init(
            value: value,
            sliderRange: sliderRange,
            step: step,
            lowerClamp: lowerClamp,
            upperClamp: upperClamp,
            controlSize: controlSize,
            decimalPlaces: decimalPlaces
        ) {
            label()
        } suffix: {
            suffix()
        } info: {
            LuminareInfoView()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        _ suffixKey: LocalizedStringKey,
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: LuminareValueAdjusterCompose.ControlSize = .regular,
        decimalPlaces: Int = 0,
        @ViewBuilder info: @escaping () -> LuminareInfoView<Info>
    ) where Label == Text, Suffix == Text {
        self.init(
            value: value,
            sliderRange: sliderRange,
            horizontalPadding: horizontalPadding,
            disabled: disabled,
            step: step,
            lowerClamp: lowerClamp,
            upperClamp: upperClamp,
            controlSize: controlSize,
            decimalPlaces: decimalPlaces
        ) {
            Text(key)
        } suffix: {
            Text(suffixKey)
        } info: {
            info()
        }
    }
    
    public init(
        _ key: LocalizedStringKey,
        _ suffixKey: LocalizedStringKey,
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        horizontalPadding: CGFloat = 8,
        disabled: Bool = false,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: LuminareValueAdjusterCompose.ControlSize = .regular,
        decimalPlaces: Int = 0
    ) where Label == Text, Suffix == Text, Info == EmptyView {
        self.init(
            key,
            suffixKey,
            value: value,
            sliderRange: sliderRange,
            horizontalPadding: horizontalPadding,
            disabled: disabled,
            step: step,
            lowerClamp: lowerClamp,
            upperClamp: upperClamp,
            controlSize: controlSize,
            decimalPlaces: decimalPlaces
        ) {
            LuminareInfoView()
        }
    }

    public var body: some View {
        VStack {
            if controlSize == .regular {
                LuminareCompose(horizontalPadding: horizontalPadding, disabled: disabled) {
                    content()
                } label: {
                    label()
                } info: {
                    info()
                }

                slider()
            } else {
                LuminareCompose(horizontalPadding: horizontalPadding, spacing: 12, disabled: disabled) {
                    HStack(spacing: 12) {
                        slider()
                        
                        content()
                    }
                    .frame(width: 270)
                } label: {
                    label()
                } info: {
                    info()
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: controlSize.height)
        .animation(LuminareConstants.animation, value: value)
        .animation(LuminareConstants.animation, value: isShowingTextBox)
    }

    func slider() -> some View {
        Slider(
            value: Binding(
                get: {
                    value
                },
                set: { newValue in
                    value = newValue
                    isShowingTextBox = false
                }
            ),
            in: sliderRange
        )
    }

    @ViewBuilder
    func content() -> some View {
        HStack {
            if isShowingTextBox {
                TextField(
                    "",
                    value: Binding(
                        get: {
                            value
                        },
                        set: {
                            if lowerClamp, upperClamp {
                                value = $0.clamped(to: sliderRange)
                            } else if lowerClamp {
                                value = max(sliderRange.lowerBound, $0)
                            } else if upperClamp {
                                value = min(sliderRange.upperBound, $0)
                            } else {
                                value = $0
                            }
                        }
                    ),
                    formatter: formatter
                )
                .onSubmit {
                    withAnimation(LuminareConstants.fastAnimation) {
                        isShowingTextBox.toggle()
                    }
                }
                .focused($focusedField, equals: .textbox)
                .multilineTextAlignment(.trailing)
                .labelsHidden()
                .textFieldStyle(.plain)
                .padding(.leading, -4)
            } else {
                Button {
                    withAnimation(LuminareConstants.fastAnimation) {
                        isShowingTextBox.toggle()
                        focusedField = .textbox
                    }
                } label: {
                    Text(String(format: "%.\(decimalPlaces)f", value as! CVarArg))
                        .contentTransition(.numericText())
                        .multilineTextAlignment(.trailing)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if Suffix.self != EmptyView.self {
                suffix()
                    .padding(.leading, -6)
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
        .onChange(of: isShowingTextBox) { _ in
            if isShowingTextBox {
                addEventMonitor()
            } else {
                removeEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
    }

    func addEventMonitor() {
        if eventMonitor != nil {
            return
        }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let downArrow: CGKeyCode = 0x7D
            let upArrow: CGKeyCode = 0x7E

            guard event.keyCode == downArrow || event.keyCode == upArrow else {
                return event
            }

            if event.keyCode == upArrow {
                value += step
            }

            if event.keyCode == downArrow {
                value -= step
            }

            if lowerClamp, upperClamp {
                value = value.clamped(to: sliderRange)
            } else if lowerClamp {
                value = max(sliderRange.lowerBound, value)
            } else if upperClamp {
                value = min(sliderRange.upperBound, value)
            } else {
                value = value
            }

            return nil
        } as? NSObject
    }

    func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    LuminareSection {
        LuminareValueAdjusterCompose(
            value: .constant(42),
            sliderRange: 0...128,
            step: 1,
            lowerClamp: true, 
            upperClamp: false
        ) {
            Text("Value Adjuster")
        } suffix: {
            Text("suffix")
        }
    }
    .padding()
}
