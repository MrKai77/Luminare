//
//  LuminareSlider.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

// MARK: - Value Adjuster (Compose)

public struct LuminareSlider<Label, Content, V, F>: View
    where Label: View, Content: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint,
    F: ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
    private enum FocusedField {
        case textbox
    }

    // MARK: Environments

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareComposeLayout) private var layout

    @FocusState private var focusedField: FocusedField?

    // MARK: Fields

    @Binding private var value: V
    @State private var lastValue: V
    private let range: ClosedRange<V>, step: V.Stride?
    private let format: F
    private let clampsUpper: Bool, clampsLower: Bool

    @ViewBuilder private var content: (AnyView) -> Content, label: () -> Label

    @State private var isTextBoxVisible: Bool = false
    @State private var isSliderHovering: Bool = false
    @State private var isSliderDebouncedHovering: Bool = false
    @State private var isSliderEditing: Bool = false

    private let id = UUID()

    // MARK: Initializers

    public init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        @ViewBuilder content: @escaping (AnyView) -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._value = value
        self.lastValue = value.wrappedValue
        self.range = range
        self.step = step
        self.format = format
        self.clampsUpper = clampsUpper
        self.clampsLower = clampsLower

        self.content = content
        self.label = label
    }

    public init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        @ViewBuilder content: @escaping (AnyView) -> Content
    ) where Label == Text {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            content: content
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        @ViewBuilder content: @escaping (AnyView) -> Content
    ) where Label == Text {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            content: content
        ) {
            Text(titleKey)
        }
    }

    public init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) where Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower
        ) { view in
            HStack(spacing: 0) {
                if let prefix {
                    prefix
                        .fontDesign(.monospaced)
                }

                view

                if let suffix {
                    suffix
                        .fontDesign(.monospaced)
                }
            }
        } label: {
            label()
        }
    }

    public init(
        _ title: some StringProtocol,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil
    ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            prefix: prefix,
            suffix: suffix
        ) {
            Text(title)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V.Stride? = nil,
        format: F,
        clampsUpper: Bool = true,
        clampsLower: Bool = true,
        prefix: Text? = nil,
        suffix: Text? = nil
    ) where Label == Text, Content == HStack<TupleView<(Text?, AnyView, Text?)>> {
        self.init(
            value: value,
            in: range,
            step: step,
            format: format,
            clampsUpper: clampsUpper,
            clampsLower: clampsLower,
            prefix: prefix,
            suffix: suffix
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
                LuminareCompose {
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
        .animation(animation, value: value)
        .animation(animation, value: isTextBoxVisible)
        .animation(animation, value: isSliderHovering)
        .animation(animation, value: isSliderDebouncedHovering)
        .animation(animation, value: isSliderEditing)
        .booleanThrottleDebounced(isSliderHovering) { debouncedValue in
            isSliderDebouncedHovering = debouncedValue
        }
    }

    private var totalRange: V {
        range.upperBound - range.lowerBound
    }

    @ViewBuilder private func slider() -> some View {
        let binding: Binding<V> = .init {
            value
        } set: { newValue in
            value = newValue
            isTextBoxVisible = false
        }

        if let step {
            Slider(
                value: binding,
                in: range,
                step: step
            ) { isEditing in
                isSliderEditing = isEditing
            }
        } else {
            Slider(
                value: binding,
                in: range
            ) { isEditing in
                isSliderEditing = isEditing
            }
        }
    }

    @ViewBuilder private func text() -> some View {
        HStack {
            let view = Group {
                if isTextBoxVisible {
                    TextField(
                        "",
                        value: .init(.init {
                            value
                        } set: { newValue in
                            if clampsLower, clampsUpper {
                                value = newValue.clamped(to: range)
                            } else if clampsLower {
                                value = max(range.lowerBound, newValue)
                            } else if clampsUpper {
                                value = min(range.upperBound, newValue)
                            } else {
                                value = newValue
                            }
                        }),
                        format: format
                    )
                    .onSubmit {
                        withAnimation(animationFast) {
                            isTextBoxVisible.toggle()
                        }
                    }
                    .focused($focusedField, equals: .textbox)
                    .multilineTextAlignment(.trailing)
                    .labelsHidden()
                    .textFieldStyle(.plain)
                    .padding(.leading, -4)
                    .fontDesign(.monospaced)
                } else {
                    Button {
                        withAnimation(animationFast) {
                            isTextBoxVisible.toggle()
                            focusedField = .textbox
                        }
                    } label: {
                        Text(format.format(value))
                            .contentTransition(.numericText(countsDown: countsDown))
                            .multilineTextAlignment(.trailing)
                            .fontDesign(.monospaced)
                    }
                    .buttonStyle(.plain)
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
            if isTextBoxVisible {
                Capsule()
                    .foregroundStyle(.quinary)
            } else {
                Capsule()
                    .foregroundStyle(.quinary.opacity(0.5))
            }
        }
        .fixedSize()
        .clipShape(.capsule)
        .onChange(of: isTextBoxVisible) { _ in
            if isTextBoxVisible {
                addEventMonitor()
            } else {
                removeEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
        .opacity(isEnabled ? 1 : 0.5)
        .onChange(of: value) { value in
            DispatchQueue.main.async {
                lastValue = value
            }
        }
    }

    private var countsDown: Bool {
        value > lastValue
    }

    // MARK: Functions

    func addEventMonitor() {
        EventMonitorManager.shared.addLocalMonitor(
            for: id,
            matching: .keyDown
        ) { event in
            let downArrow: CGKeyCode = 0x7D
            let upArrow: CGKeyCode = 0x7E

            guard event.keyCode == downArrow || event.keyCode == upArrow else {
                return event
            }

            let isShiftDown = event.modifierFlags.contains(.shift) // x10
            let isOptionDown = event.modifierFlags.contains(.option) // x0.1
            let acceleration: V = if isShiftDown, isOptionDown {
                1
            } else if isShiftDown {
                10
            } else if isOptionDown {
                0.1
            } else {
                1
            }
            let step = V(step ?? 1)

            if event.keyCode == upArrow {
                value += step * acceleration
            }

            if event.keyCode == downArrow {
                value -= step * acceleration
            }

            if clampsLower, clampsUpper {
                value = value.clamped(to: range)
            } else if clampsLower {
                value = max(range.lowerBound, value)
            } else if clampsUpper {
                value = min(range.upperBound, value)
            } else {
                value = value
            }

            return nil
        }
    }

    func removeEventMonitor() {
        EventMonitorManager.shared.removeMonitor(for: id)
    }
}

// MARK: - Preview

@available(macOS 15.0, *)
#Preview(
    "LuminareSlider",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var value: Double = 42

    LuminareSection {
        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            VStack(alignment: .leading) {
                Text("Slide to stride")

                Text("Composed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            VStack(alignment: .leading) {
                Text("Slide to stride")

                Text("Composed, Compact")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .luminareComposeLayout(.compact)

        LuminareSlider(
            "2 Decimal Places",
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )

        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
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
