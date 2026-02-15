//
//  LuminareSlider.swift
//  Luminare
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public enum LuminareSliderLayout: Equatable, Hashable, Identifiable, Codable, Sendable {
    case regular
    case compact(textBoxWidth: CGFloat? = nil, moveTextBoxToLeadingOnDrag: Bool = false)

    public var id: Self { self }

    var controlSizeMinHeight: CGFloat? {
        switch self {
        case .regular:
            70
        case .compact:
            nil
        }
    }
}

public extension LuminareSliderLayout {
    static var compact: Self { .compact() }
}

// MARK: - Slider (Compose)

public struct LuminareSlider<Label, Content, V, F>: View
    where Label: View, Content: View, V: Strideable & BinaryFloatingPoint, V.Stride: BinaryFloatingPoint,
    F: ParseableFormatStyle, F.FormatInput == V, F.FormatOutput == String {
    private enum FocusedField {
        case textbox
    }

    // MARK: Environments

    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast
    @Environment(\.luminareSectionHorizontalPadding) private var horizontalPadding
    @Environment(\.luminareSliderLayout) private var layout

    @FocusState private var focusedField: FocusedField?

    // MARK: Fields

    @Binding private var value: V
    @State private var internalValue: V
    @State private var lastValue: V
    private let range: ClosedRange<V>, step: V.Stride?
    private let format: F
    private let clampsUpper: Bool, clampsLower: Bool

    @ViewBuilder private var content: (AnyView) -> Content, label: () -> Label

    @State private var isTextBoxVisible: Bool = false
    @State private var isSliderHovering: Bool = false
    @State private var isSliderDebouncedHovering: Bool = false
    @State private var isSliderEditing: Bool = false
    @State private var composeWidth: CGFloat = .zero

    private let id: UUID = .init()

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
        self.internalValue = value.wrappedValue
        self.lastValue = value.wrappedValue
        self.range = range
        self.step = step
        self.format = format
        self.clampsUpper = clampsUpper
        self.clampsLower = clampsLower

        self.content = content
        self.label = label
    }

    @_disfavoredOverload
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

    @_disfavoredOverload
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
                    textBoxView()
                        .fixedSize()
                } label: {
                    label()
                }

                sliderView()
                    .padding(.horizontal, horizontalPadding)
            case let .compact(textBoxWidth, moveTextBoxToLeadingOnDrag):
                if !moveTextBoxToLeadingOnDrag {
                    LuminareCompose {
                        HStack {
                            sliderView()

                            textBoxView()
                                .frame(width: textBoxWidth)
                                .fixedSize()
                        }
                        .frame(maxWidth: composeWidth * 0.7, alignment: .trailing)
                    } label: {
                        label()
                    }
                } else {
                    let isAlternativeTextBoxVisible = isSliderDebouncedHovering || isSliderEditing

                    LuminareCompose {
                        HStack {
                            sliderView()

                            if !isAlternativeTextBoxVisible {
                                textBoxView()
                                    .frame(width: textBoxWidth)
                                    .fixedSize()
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .frame(maxWidth: isAlternativeTextBoxVisible ? nil : composeWidth * 0.7, alignment: .trailing)
                    } label: {
                        if isAlternativeTextBoxVisible {
                            textBoxView()
                                .frame(width: textBoxWidth)
                                .fixedSize()
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            label()
                        }
                    }
                }
            }
        }
        .frame(minHeight: layout.controlSizeMinHeight)
        .animation(animation, value: value)
        .animation(animation, value: isTextBoxVisible)
        .animation(animation, value: isSliderHovering)
        .animation(animation, value: isSliderDebouncedHovering)
        .animation(animation, value: isSliderEditing)
        .booleanThrottleDebounced(isSliderHovering) { debouncedValue in
            isSliderDebouncedHovering = debouncedValue
        }
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { newValue in
            composeWidth = newValue
        }
        .onChange(of: value) { _ in // If value changes externally, reflect that internally
            internalValue = value
        }
    }

    private var countsDown: Bool {
        value > lastValue
    }

    @ViewBuilder private func sliderView() -> some View {
        let binding = Binding<V> {
            value
        } set: { newValue in
            value = newValue
            isTextBoxVisible = false
        }

        Group {
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
        .onHover { isSliderHovering = $0 }
    }

    @ViewBuilder private func textBoxView() -> some View {
        HStack {
            if isTextBoxVisible {
                let textFieldView = TextField(
                    value: $internalValue,
                    format: format
                ) {
                    EmptyView()
                }
                .labelsHidden()
                .textFieldStyle(.plain)
                .focused($focusedField, equals: .textbox)
                .multilineTextAlignment(.trailing)
                .padding(.leading, -4)
                .fontDesign(.monospaced)
                .onSubmit(commit)
                .onChange(of: focusedField == .textbox) { if !$0 { commit() } }

                content(.init(textFieldView))
            } else {
                let textView = Text(format.format(value))
                    .contentTransition(.numericText(countsDown: countsDown))
                    .multilineTextAlignment(.trailing)
                    .fontDesign(.monospaced)

                Button {
                    withAnimation(animationFast) {
                        isTextBoxVisible.toggle()
                        focusedField = .textbox
                    }
                } label: {
                    content(.init(textView))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
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
        .onChange(of: value) { value in
            DispatchQueue.main.async {
                lastValue = value
            }
        }
    }

    // MARK: Functions

    private func commit() {
        if clampsLower, clampsUpper {
            value = internalValue.clamped(to: range)
        } else if clampsLower {
            value = max(range.lowerBound, internalValue)
        } else if clampsUpper {
            value = min(range.upperBound, internalValue)
        } else {
            value = internalValue
        }
        internalValue = value

        withAnimation(animationFast) {
            isTextBoxVisible = false
        }
    }

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
            "2 Decimal Places",
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )
        .luminareSliderLayout(.compact(textBoxWidth: 100))

        LuminareSlider(
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...3)),
            prefix: Text("#")
        ) {
            Text("With an info")
                .luminareToolTip(attachedTo: .topTrailing) {
                    Text("Incididunt Lorem pariatur eiusmod laboris laboris.")
                        .padding()
                }
        }

        LuminareSlider(
            "With a sliding textbox",
            value: $value,
            in: 0...128,
            format: .number.precision(.fractionLength(0...2)),
            prefix: Text("#")
        )
        .luminareSliderLayout(.compact(textBoxWidth: 100, moveTextBoxToLeadingOnDrag: true))
    }
}
