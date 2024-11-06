//
//  LuminareValueAdjusterCompose.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public enum LuminareValueAdjusterControlSize {
    case regular
    case compact
    
    var height: CGFloat {
        switch self {
        case .regular: 70
        case .compact: 34
        }
    }
}

// MARK: - Value Adjuster (Compose)

public struct LuminareValueAdjusterCompose<Label, Content, V>: View where Label: View, Content: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    public typealias ControlSize = LuminareValueAdjusterControlSize
    
    private enum FocusedField {
        case textbox
    }
    
    // MARK: Environments
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    // MARK: Fields

    private let horizontalPadding: CGFloat

    private let formatter: NumberFormatter
    private var totalRange: V {
        sliderRange.upperBound - sliderRange.lowerBound
    }

    @State private var isShowingTextBox = false

    @FocusState private var focusedField: FocusedField?

    @ViewBuilder private let content: (AnyView) -> Content
    @ViewBuilder private let label: () -> Label
    
    @Binding private var value: V
    private let sliderRange: ClosedRange<V>
    private var step: V
    private let upperClamp: Bool
    private let lowerClamp: Bool
    private let controlSize: ControlSize
    private let decimalPlaces: Int
    
    @State var eventMonitor: AnyObject?
    
    // MARK: Initializers

    // TODO: max digit spacing for label
    public init(
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        horizontalPadding: CGFloat = 8,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: ControlSize = .regular,
        decimalPlaces: Int = 0,
        @ViewBuilder content: @escaping (AnyView) -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.label = label
        
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
    }
    
    public init(
        _ key: LocalizedStringKey,
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        horizontalPadding: CGFloat = 8,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: ControlSize = .regular,
        decimalPlaces: Int = 0,
        @ViewBuilder content: @escaping (AnyView) -> Content
    ) where Label == Text {
        self.init(
            value: value,
            sliderRange: sliderRange,
            horizontalPadding: horizontalPadding,
            step: step,
            lowerClamp: lowerClamp,
            upperClamp: upperClamp,
            controlSize: controlSize,
            decimalPlaces: decimalPlaces,
            content: content
        ) {
            Text(key)
        }
    }
    
    // MARK: Body

    public var body: some View {
        VStack {
            if controlSize == .regular {
                LuminareCompose(horizontalPadding: horizontalPadding) {
                    text()
                } label: {
                    label()
                }

                slider()
                    .padding(.horizontal, horizontalPadding)
            } else {
                LuminareCompose(horizontalPadding: horizontalPadding, spacing: 12) {
                    HStack(spacing: 12) {
                        slider()
                        
                        text()
                    }
                    .frame(width: 270)
                } label: {
                    label()
                }
            }
        }
        .frame(height: controlSize.height)
        .animation(animation, value: value)
        .animation(animation, value: isShowingTextBox)
    }

    @ViewBuilder private func slider() -> some View {
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

    @ViewBuilder private func text() -> some View {
        HStack {
            let view = Group {
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
                        withAnimation(animationFast) {
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
                        withAnimation(animationFast) {
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
            }
            
            content(.init(view))
        }
        .frame(maxWidth: 150)
        .padding(4)
        .padding(.horizontal, 4)
        .background {
            Capsule()
                .strokeBorder(.quaternary, lineWidth: 1)
        }
        .background {
            if isShowingTextBox {
                Capsule()
                    .foregroundStyle(.quinary)
            } else {
                Capsule()
                    .foregroundStyle(.quinary.opacity(0.5))
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
        .opacity(isEnabled ? 1 : 0.5)
    }
    
    // MARK: Functions

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

// MARK: - Preview

#Preview("LuminareValueAdjusterCompose") {
    LuminareSection {
        LuminareValueAdjusterCompose(
            value: .constant(42),
            sliderRange: 0...128,
            step: 1,
            lowerClamp: true, 
            upperClamp: false
        ) { view in
            HStack(spacing: 0) {
                Text("#")
                view
            }
            .monospaced()
        } label: {
            VStack(alignment: .leading) {
                Text("Slide to stride")
                
                Text("Composed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        
        
        LuminareValueAdjusterCompose(
            value: .constant(42),
            sliderRange: 0...128,
            step: 1,
            lowerClamp: true,
            upperClamp: false,
            controlSize: .compact
        ) { button in
            HStack(spacing: 0) {
                Text("#")
                button
            }
            .monospaced()
        } label: {
            VStack(alignment: .leading) {
                Text("Slide to stride")
                
                Text("Composed, Compact")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding()
}
